package validator

import (
	"fmt"
	"time"
)

// ValidateUsiaBalita checks if a birthdate corresponds to age 0-59 months
func ValidateUsiaBalita(tanggalLahir time.Time) error {
	now := time.Now()
	if tanggalLahir.After(now) {
		return fmt.Errorf("tanggal lahir tidak boleh di masa depan")
	}

	// Calculate age in months
	months := (now.Year()-tanggalLahir.Year())*12 + int(now.Month()) - int(tanggalLahir.Month())
	if now.Day() < tanggalLahir.Day() {
		months--
	}

	if months < 0 || months > 59 {
		return fmt.Errorf("usia balita harus 0-59 bulan (usia saat ini: %d bulan)", months)
	}
	return nil
}

// ValidatePengukuran validates measurement values
func ValidatePengukuran(tinggiBadan, beratBadan float64, lila, lingkarKepala *float64) error {
	if tinggiBadan <= 0 || tinggiBadan > 150 {
		return fmt.Errorf("tinggi badan harus antara 0 dan 150 cm")
	}
	if beratBadan <= 0 || beratBadan > 50 {
		return fmt.Errorf("berat badan harus antara 0 dan 50 kg")
	}
	if lila != nil && (*lila <= 0 || *lila > 50) {
		return fmt.Errorf("LILA harus antara 0 dan 50 cm")
	}
	if lingkarKepala != nil && (*lingkarKepala <= 0 || *lingkarKepala > 60) {
		return fmt.Errorf("lingkar kepala harus antara 0 dan 60 cm")
	}
	return nil
}

// ValidateJenisKelamin validates gender value
func ValidateJenisKelamin(jk string) error {
	if jk != "L" && jk != "P" {
		return fmt.Errorf("jenis kelamin harus 'L' atau 'P'")
	}
	return nil
}

// ValidateKategoriRisiko validates risk category
func ValidateKategoriRisiko(kategori string) error {
	valid := map[string]bool{
		"rendah": true,
		"sedang": true,
		"tinggi": true,
	}
	if !valid[kategori] {
		return fmt.Errorf("kategori risiko harus 'rendah', 'sedang', atau 'tinggi'")
	}
	return nil
}
