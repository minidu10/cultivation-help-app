# Deployment

AgroMaster on a free-tier EC2 instance, powered off between demos.

The database lives on Neon, off the instance, so **stopping the server loses no
data**. The instance holds only the application.

---

## Cost

| | |
|---|---|
| t3.micro, 750 h/month | $0 |
| 30 GB EBS | $0 |
| Public IPv4, 750 h/month | $0 |
| Elastic IP | not used — AWS bills for one attached to a *stopped* instance |
| Neon, DuckDNS | $0 |

Check **Billing → Free tier** for what your account actually includes; AWS
changed the terms in 2025.

---

## First-time setup

### 1. DuckDNS

Sign in at [duckdns.org](https://www.duckdns.org) with Google, create a
subdomain, and copy the token from the top of the page. Free, no card.

This is what keeps the URL stable: EC2 assigns a new public IP on every start,
and a boot script tells DuckDNS about it.

### 2. Launch the instance

Region **ap-southeast-1 (Singapore)** — the same region as the Neon database,
which keeps query round-trips in single digits of milliseconds.

| | |
|---|---|
| AMI | Ubuntu Server 24.04 LTS |
| Type | t3.micro |
| Storage | 30 GB gp3 |
| Key pair | create, download the `.pem`, keep it — it cannot be re-downloaded |

Inbound rules: **SSH 22 from My IP**, **HTTP 80** and **HTTPS 443** from
anywhere. Port 22 open to the world is brute-forced within hours.

### 3. Run the bootstrap

```bash
ssh -i agromaster-key.pem ubuntu@<public-ip>
git clone https://github.com/minidu10/cultivation-help-app.git
cd cultivation-help-app
bash deploy/bootstrap.sh
```

It installs Docker, asks for your credentials, writes `.env`, issues the TLS
certificate, pulls the images CI published and installs the boot service.
Two to three minutes. Re-running it is safe.

### What actually gets installed

Only three things, because **nothing is compiled here**:

| | |
|---|---|
| Docker + compose plugin | runs the containers |
| certbot | issues and renews the TLS certificate |
| ca-certificates, curl, gnupg | needed to add Docker's apt repository |

No Java, no Maven, no Node, no JDK. GitHub Actions builds the images and
publishes them to ghcr.io; this machine only pulls. You can confirm it
afterwards — `which java mvn node` finds nothing.

### 4. Google sign-in

Add `https://<your-subdomain>.duckdns.org` to **Authorised JavaScript origins**
on your OAuth client, alongside the localhost entry. Without it the button
fails in production exactly as it did locally.

---

## Showing it to someone

**Start** — EC2 → Instances → select → *Instance state* → **Start instance**.

Wait about **90 seconds**. Everything is automatic: DNS is updated, containers
start, the certificate is checked.

**Check** — open `https://<your-subdomain>.duckdns.org` and confirm:

- the page loads with a valid certificate
- you can log in
- the dashboard shows crops and the profit chart
- the AI advisor answers a question

**Stop afterwards** — *Instance state* → **Stop instance**. Billing for compute
stops; the disk and your data are untouched.

Nothing needs to be typed on the server for any of this.

---

## When something is wrong

SSH in, then:

```bash
sudo journalctl -u agromaster -n 50      # what the boot sequence did
docker compose ps                        # all three should be (healthy)
docker compose logs backend --tail 50
```

| Symptom | Cause |
|---|---|
| Site unreachable, instance running | DNS not updated — `sudo bash deploy/update-dns.sh` |
| Certificate warning | Expired while powered off; `sudo certbot renew --webroot -w /var/www/certbot` then reload |
| Backend unhealthy | Usually Neon credentials — `docker compose logs backend \| grep -i password` |
| Google button missing | `GOOGLE_CLIENT_ID` empty in `.env` |

Give it a minute before concluding something is broken: the backend takes
roughly 30 seconds to become healthy, and its healthcheck allows for that.

---

## Updating the deployed app

```bash
cd ~/cultivation-help-app
git pull
docker compose up -d --build
```

Only this needs `--build`. Boot deliberately does not, so a power-on is
90 seconds rather than five minutes.

---

## Moving to a real domain

Point an A record at the instance's current IP, then:

```bash
sudo certbot certonly --standalone -d yourdomain.com   # stop the frontend first
sed -i 's/^DOMAIN=.*/DOMAIN=yourdomain.com/' .env
docker compose up -d
```

Add the new origin to Google OAuth as well.

With an IP that changes on every start, a purchased domain needs the same
dynamic update DuckDNS is doing — keep DuckDNS as a CNAME target, or use a DNS
provider with an API and adapt `deploy/update-dns.sh`.
