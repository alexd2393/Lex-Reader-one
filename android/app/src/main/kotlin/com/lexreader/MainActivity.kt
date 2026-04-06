package com.lexreader

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.apache.poi.xslf.usermodel.XMLSlideShow
import org.apache.poi.xwpf.usermodel.*
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.lexreader/converter"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ── DOCX → HTML ──────────────────────────────────────────
                    "docxToHtml" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("INVALID_ARG", "path requerido", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val html = convertDocxToHtml(path)
                                runOnUiThread { result.success(html) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("DOCX_ERROR", e.message, null)
                                }
                            }
                        }.start()
                    }

                    // ── PPTX → imágenes PNG ───────────────────────────────────
                    "pptxToImages" -> {
                        val path = call.argument<String>("path")
                        val outDir = call.argument<String>("outDir")
                        if (path == null || outDir == null) {
                            result.error("INVALID_ARG", "path y outDir requeridos", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val paths = convertPptxToImages(path, outDir)
                                runOnUiThread { result.success(paths) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("PPTX_ERROR", e.message, null)
                                }
                            }
                        }.start()
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DOCX → HTML
    // Extrae párrafos, headings, negrita, cursiva, tablas e imágenes embebidas.
    // ─────────────────────────────────────────────────────────────────────────
    private fun convertDocxToHtml(filePath: String): String {
        val doc = XWPFDocument(FileInputStream(filePath))
        val sb = StringBuilder()
        sb.append("<html><body>")

        for (element in doc.bodyElements) {
            when (element) {
                is XWPFParagraph -> sb.append(paragraphToHtml(element))
                is XWPFTable     -> sb.append(tableToHtml(element))
            }
        }

        sb.append("</body></html>")
        doc.close()
        return sb.toString()
    }

    private fun paragraphToHtml(para: XWPFParagraph): String {
        if (para.text.isBlank()) return "<br/>"

        val style = para.style ?: ""
        val tag = when {
            style.startsWith("Heading1") || style == "1" -> "h1"
            style.startsWith("Heading2") || style == "2" -> "h2"
            style.startsWith("Heading3") || style == "3" -> "h3"
            else -> "p"
        }

        val innerSb = StringBuilder()
        for (run in para.runs) {
            var text = escapeHtml(run.text() ?: "")
            if (run.isBold)   text = "<strong>$text</strong>"
            if (run.isItalic) text = "<em>$text</em>"
            if (run.isStrikeThrough) text = "<s>$text</s>"
            innerSb.append(text)
        }

        return "<$tag>$innerSb</$tag>"
    }

    private fun tableToHtml(table: XWPFTable): String {
        val sb = StringBuilder("<table border='1' cellpadding='6'>")
        for ((rowIdx, row) in table.rows.withIndex()) {
            sb.append("<tr>")
            for (cell in row.tableCells) {
                val cellTag = if (rowIdx == 0) "th" else "td"
                sb.append("<$cellTag>${escapeHtml(cell.text)}</$cellTag>")
            }
            sb.append("</tr>")
        }
        sb.append("</table>")
        return sb.toString()
    }

    private fun escapeHtml(text: String): String =
        text.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")

    // ─────────────────────────────────────────────────────────────────────────
    // PPTX → imágenes PNG
    // Renderiza cada slide en un Bitmap y lo guarda en outDir.
    // ─────────────────────────────────────────────────────────────────────────
    private fun convertPptxToImages(filePath: String, outDir: String): List<String> {
        val show = XMLSlideShow(FileInputStream(filePath))
        val dim  = show.pageSize

        // Resolución: escala a 1280px de ancho manteniendo el aspect ratio
        val targetW = 1280
        val scale   = targetW.toFloat() / dim.width.toFloat()
        val targetH = (dim.height * scale).toInt()

        val outPaths = mutableListOf<String>()
        val prefix = "lexreader_pptx_${System.currentTimeMillis()}"

        for ((i, slide) in show.slides.withIndex()) {
            val bitmap = Bitmap.createBitmap(targetW, targetH, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)

            // Fondo blanco base
            canvas.drawColor(Color.WHITE)

            // Escalar el canvas al tamaño del slide
            canvas.scale(scale, scale)

            // Dibujar el slide usando la API de Drawing2D de POI
            slide.draw(canvas)

            // Guardar PNG
            val outFile = File(outDir, "${prefix}_slide_${i + 1}.png")
            FileOutputStream(outFile).use { fos ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 92, fos)
            }
            bitmap.recycle()
            outPaths.add(outFile.absolutePath)
        }

        show.close()
        return outPaths
    }
}
