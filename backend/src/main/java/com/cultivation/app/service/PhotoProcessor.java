package com.cultivation.app.service;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Iterator;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import com.cultivation.app.exception.ApiException;

/**
 * Turns an uploaded photo into the two images the crop doctor needs.
 *
 * Uploads are untrusted bytes. The type is read from the file's own header,
 * never its name or the client's Content-Type. The dimensions are read before
 * any pixels are decoded, so a small file claiming to be 50,000 pixels square
 * is refused instead of exhausting the heap. Everything is re-encoded, which
 * also drops EXIF metadata, GPS position included, before the image goes
 * anywhere else.
 */
@Component
public class PhotoProcessor {

    static final long MAX_BYTES = 5L * 1024 * 1024;
    static final int MAX_SIDE = 8_000;
    static final long MAX_PIXELS = 40_000_000L;

    /** Enough detail for a model to see lesions; small enough to send quickly. */
    static final int AI_SIDE = 1024;
    /** What the history list shows. */
    static final int THUMB_SIDE = 320;

    public record Prepared(byte[] forAi, byte[] thumbnail) {
    }

    public Prepared prepare(byte[] upload) {
        if (upload == null || upload.length == 0) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Choose a photo to check");
        }
        if (upload.length > MAX_BYTES) {
            throw new ApiException(HttpStatus.CONTENT_TOO_LARGE, "That photo is too large. The limit is 5 MB.");
        }
        if (!isJpeg(upload) && !isPng(upload)) {
            throw new ApiException(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "Use a JPEG or PNG photo");
        }

        BufferedImage rgb = flatten(decode(upload));
        return new Prepared(jpeg(fit(rgb, AI_SIDE), 0.85f), jpeg(fit(rgb, THUMB_SIDE), 0.75f));
    }

    static boolean isJpeg(byte[] b) {
        return b.length > 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF;
    }

    static boolean isPng(byte[] b) {
        byte[] signature = {(byte) 0x89, 'P', 'N', 'G', '\r', '\n', 0x1A, '\n'};
        if (b.length < signature.length) {
            return false;
        }
        for (int i = 0; i < signature.length; i++) {
            if (b[i] != signature[i]) {
                return false;
            }
        }
        return true;
    }

    private static BufferedImage decode(byte[] upload) {
        try (ImageInputStream in = ImageIO.createImageInputStream(new ByteArrayInputStream(upload))) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(in);
            if (!readers.hasNext()) {
                throw unreadable();
            }
            ImageReader reader = readers.next();
            try {
                reader.setInput(in, true, true);
                // Header only: no pixel has been decoded yet.
                long width = reader.getWidth(0);
                long height = reader.getHeight(0);
                if (width > MAX_SIDE || height > MAX_SIDE || width * height > MAX_PIXELS) {
                    throw new ApiException(HttpStatus.CONTENT_TOO_LARGE,
                        "That photo's resolution is too high. Take it again at a normal camera setting.");
                }
                BufferedImage image = reader.read(0);
                if (image == null) {
                    throw unreadable();
                }
                return image;
            } finally {
                reader.dispose();
            }
        } catch (IOException | RuntimeException ex) {
            if (ex instanceof ApiException api) {
                throw api;
            }
            throw unreadable();
        }
    }

    private static ApiException unreadable() {
        return new ApiException(HttpStatus.BAD_REQUEST, "That photo could not be read. Try taking it again.");
    }

    /** Opaque RGB on white: transparent PNG areas would otherwise turn black in JPEG. */
    private static BufferedImage flatten(BufferedImage source) {
        BufferedImage rgb = new BufferedImage(source.getWidth(), source.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = rgb.createGraphics();
        try {
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, rgb.getWidth(), rgb.getHeight());
            g.drawImage(source, 0, 0, null);
        } finally {
            g.dispose();
        }
        return rgb;
    }

    /**
     * Scales the longer side down to {@code side}, never up. Large reductions
     * are done in halving steps, since one bilinear pass from 4000 px to 320 px
     * skips most of the pixels and comes out jagged.
     */
    static BufferedImage fit(BufferedImage image, int side) {
        BufferedImage current = image;
        int longest = Math.max(current.getWidth(), current.getHeight());
        while (longest > side) {
            int next = Math.max(side, longest / 2);
            double scale = (double) next / longest;
            current = resize(current,
                Math.max(1, (int) Math.round(current.getWidth() * scale)),
                Math.max(1, (int) Math.round(current.getHeight() * scale)));
            longest = Math.max(current.getWidth(), current.getHeight());
        }
        return current;
    }

    private static BufferedImage resize(BufferedImage image, int width, int height) {
        BufferedImage out = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = out.createGraphics();
        try {
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g.drawImage(image, 0, 0, width, height, null);
        } finally {
            g.dispose();
        }
        return out;
    }

    static byte[] jpeg(BufferedImage image, float quality) {
        ImageWriter writer = ImageIO.getImageWritersByFormatName("jpeg").next();
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (ImageOutputStream out = ImageIO.createImageOutputStream(bytes)) {
            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(quality);
            writer.setOutput(out);
            writer.write(null, new IIOImage(image, null, null), param);
        } catch (IOException ex) {
            throw new IllegalStateException("JPEG encoding failed", ex);
        } finally {
            writer.dispose();
        }
        return bytes.toByteArray();
    }
}
