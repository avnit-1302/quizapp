package no.itszipzon.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

/**
 * Service for sending emails.
 */
@Service
public class EmailService {

  @Autowired
  private JavaMailSender mailSender;

  /**
   * Method to send an email.
   *
   * @param to email to send to
   * @param subject subject of the email
   * @param body body of the email
   */
  public void sendEmail(String to, String subject, String body) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setTo(to);
    message.setSubject(subject);
    message.setText(body);
    message.setFrom("gruppeseks123@gmail.com");
    mailSender.send(message);
  }

  /**
   * Method to send an email with HTML.
   *
   * @param to email to send to
   * @param subject subject of the email
   * @param filePath path to the HTML file
   * @param replacements replacements to make in the HTML file
   */
  public void sendHtmlEmail(String to, String subject, String filePath,
      Map<String, String> replacements) throws MessagingException, IOException {
    MimeMessage message = mailSender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
    helper.setTo(to);
    helper.setSubject(subject);
    helper.setText(loadHtmlTemplate(filePath, replacements), true);
    helper.setFrom("gruppeseks123@gmail.com");
    mailSender.send(message);
  }

  private String loadHtmlTemplate(String filePath, Map<String, String> replacements)
      throws IOException {
    String content = new String(Files.readAllBytes(Paths.get(filePath)));
    for (Map.Entry<String, String> entry : replacements.entrySet()) {
      content = content.replace("{{" + entry.getKey() + "}}", entry.getValue());
    }
    return content;
  }
}
