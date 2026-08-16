package notification

import (
	"fmt"
	"net/smtp"

	"github.com/af133/stunguard/internal"
)

type Notifier interface {
	SendEmail(to []string, subject, body string) error
	SendAlertNotification(email string, balitaNama string, kategoriRisiko string) error
}

type SMTPNotifier struct {
	Config *internal.Config
}

func NewSMTPNotifier() *SMTPNotifier {
	return &SMTPNotifier{
		Config: internal.LoadConfig(),
	}
}

func (n *SMTPNotifier) SendEmail(to []string, subject, body string) error {
	if n.Config.SMTPHost == "" || n.Config.SMTPPort == "" {
		fmt.Println("Warning: SMTP configuration is missing. Email not sent.")
		return nil
	}

	auth := smtp.PlainAuth("", n.Config.SMTPUser, n.Config.SMTPPass, n.Config.SMTPHost)

	msg := []byte("To: " + to[0] + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"\r\n" +
		body + "\r\n")

	addr := fmt.Sprintf("%s:%s", n.Config.SMTPHost, n.Config.SMTPPort)
	err := smtp.SendMail(addr, auth, n.Config.SMTPFrom, to, msg)
	if err != nil {
		return err
	}
	return nil
}

func (n *SMTPNotifier) SendAlertNotification(email string, balitaNama string, kategoriRisiko string) error {
	subject := fmt.Sprintf("Alert StuntGuard: Deteksi Risiko %s pada Balita", kategoriRisiko)
	body := fmt.Sprintf("Halo,\n\nSistem StuntGuard mendeteksi risiko stunting dengan kategori '%s' pada balita bernama %s. Mohon segera cek dashboard untuk informasi lebih lanjut dan tindakan intervensi.\n\nTerima kasih,\nTim StuntGuard", kategoriRisiko, balitaNama)

	return n.SendEmail([]string{email}, subject, body)
}
