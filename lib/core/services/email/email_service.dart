import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../models/payment_receipt_model.dart';
import '../database_service.dart';

class EmailService {
  // Configuración de la cuenta de la empresa
  // Se obtiene dinámicamente de la tabla profile_admin
  static const String _appPassword = 'bosd umbu gdwp yymo'; 

  final _dbService = DatabaseService();

  Future<bool> sendPaymentConfirmationEmail({
    required PaymentReceiptModel receipt,
    required String customerEmail,
    required String orderId,
    File? receiptImage,
  }) async {
    // 1. Obtener el correo de la empresa desde el perfil administrativo en la BD
    final adminProfile = await _dbService.getAdminProfile();
    final companyEmail = adminProfile?.correoElectronico;

    if (companyEmail == null || companyEmail.isEmpty) {
      debugPrint('Error: Correo de empresa no configurado en profile_admin');
      return false;
    }
    
    final smtpServer = gmail(companyEmail, _appPassword);

    // Crear el mensaje
    final message = Message()
      ..from = Address(companyEmail, 'Jolus Services')
      ..recipients.add(customerEmail)
      ..bccRecipients.add(companyEmail) // Copia oculta a la empresa
      ..subject = 'Confirmación de Reporte de Pago - Pedido #$orderId'
      ..html = """
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; border: 1px solid #eee; padding: 20px;">
          <h2 style="color: #1F6FE5; text-align: center;">¡Hemos recibido tu reporte de pago!</h2>
          <p>Hola <strong>${receipt.fullName}</strong>,</p>
          <p>Gracias por realizar tu pago. Hemos recibido la información de tu comprobante y nuestro equipo procederá con la verificación.</p>
          
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <h3 style="margin-top: 0; font-size: 16px;">Resumen del Reporte:</h3>
            <ul style="list-style: none; padding: 0;">
              <li><strong>ID del Pedido:</strong> #$orderId</li>
              <li><strong>Monto Reportado:</strong> \$${receipt.amount.toStringAsFixed(2)}</li>
              <li><strong>Banco:</strong> ${receipt.bankName}</li>
              <li><strong>Nº de Comprobante:</strong> ${receipt.receiptNumber}</li>
              <li><strong>Fecha de Reporte:</strong> ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</li>
            </ul>
          </div>
          
          <p style="font-size: 14px; color: #666;">
            <strong>Nota importante:</strong> Tu pago se procesará en un plazo de 1 a 3 días hábiles. Una vez verificado, recibirás una notificación de actualización de tu pedido.
          </p>
          
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          
          <p style="text-align: center; font-size: 12px; color: #999;">
            Este es un correo automático, por favor no respondas a este mensaje.<br>
            &copy; ${DateTime.now().year} Jolus Services. Todos los derechos reservados.
          </p>
        </div>
      """;

    // Agregar el comprobante como adjunto si existe
    if (receiptImage != null && await receiptImage.exists()) {
      message.attachments.add(FileAttachment(receiptImage)
        ..location = Location.attachment
        ..fileName = 'comprobante_pago_$orderId.jpg');
    }

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Correo enviado: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      debugPrint('Error al enviar correo: $e');
      for (var p in e.problems) {
        debugPrint('Problema: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
