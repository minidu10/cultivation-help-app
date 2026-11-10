package com.cultivation.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.cultivation.app.entity.CropDiagnosisThumbnail;

@Repository
public interface CropDiagnosisThumbnailRepository extends JpaRepository<CropDiagnosisThumbnail, Long> {
}
