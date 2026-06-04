import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:excel/excel.dart' hide Border; 
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final supabase = Supabase.instance.client;
  
  bool isLoading = true;
  List<Map<String, dynamic>> datosReporte = [];
  List<Map<String, dynamic>> datosFiltrados = [];
  
  final TextEditingController _searchController = TextEditingController();
  String _filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _searchController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── FUNCIÓN CENTRALIZADA PARA FORMATEAR FECHA ──
  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null || fechaIso.isEmpty) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(fechaIso).toLocal();
      final dia = dt.day.toString().padLeft(2, '0');
      final mes = dt.month.toString().padLeft(2, '0');
      return '$dia/$mes/${dt.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _aplicarFiltros() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      datosFiltrados = datosReporte.where((fila) {
        final nombre = (fila['nombre'] ?? '').toString().toLowerCase();
        final id = (fila['id'] ?? '').toString().toLowerCase();
        final estado = (fila['estado'] ?? '').toString();
        final fecha = _formatearFecha(fila['created_at']?.toString()).toLowerCase();
        
        final coincideTexto = nombre.contains(query) || id.contains(query) || fecha.contains(query);
        final coincideEstado = _filtroEstado == 'Todos' || estado == _filtroEstado;
        return coincideTexto && coincideEstado;
      }).toList();
    });
  }

  Future<void> _cargarDatos() async {
    try {
      final data = await supabase.from('clientes').select();
      if (mounted) {
        setState(() {
          datosReporte = List<Map<String, dynamic>>.from(data);
          datosFiltrados = datosReporte;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // EXPORTAR A EXCEL (Ahora con ESTILOS Y DISEÑO)
  // ─────────────────────────────────────────────────────────
  Future<void> _exportarExcel() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Reporte'];
    excel.setDefaultSheet('Reporte');

    // 1. Estilos para el título y encabezados
    CellStyle estiloTitulo = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#2E7D32'), // Letra verde oscuro
    );

    CellStyle estiloEncabezado = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'), // Letra blanca
      backgroundColorHex: ExcelColor.fromHexString('#2E7D32'), // Fondo verde oscuro
      horizontalAlign: HorizontalAlign.Center,
    );

    // 2. Escribir el Título Principal
    var celdaTitulo = sheet.cell(CellIndex.indexByString("A1"));
    celdaTitulo.value = TextCellValue('REPORTE DE CLIENTES - ECORECOLECTOR');
    celdaTitulo.cellStyle = estiloTitulo;

    // 3. Ajustar los anchos de las columnas para que no se apachurren
    sheet.setColumnWidth(0, 15.0); // ID
    sheet.setColumnWidth(1, 15.0); // Fecha
    sheet.setColumnWidth(2, 30.0); // Nombre
    sheet.setColumnWidth(3, 15.0); // Teléfono
    sheet.setColumnWidth(4, 40.0); // Dirección
    sheet.setColumnWidth(5, 12.0); // Estado

    // 4. Escribir los encabezados con estilo (Fila 3)
    List<String> encabezados = ['ID de Registro', 'Fecha', 'Nombre del Cliente', 'Teléfono', 'Dirección Completa', 'Estado'];
    for (int col = 0; col < encabezados.length; col++) {
      var celda = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2));
      celda.value = TextCellValue(encabezados[col]);
      celda.cellStyle = estiloEncabezado;
    }

    // 5. Llenar los datos reales (A partir de la Fila 4)
    int filaActual = 3; 
    for (var cliente in datosFiltrados) {
      String idCompleto = cliente['id'].toString();
      String idCorto = idCompleto.length > 8 ? '${idCompleto.substring(0, 8)}...' : idCompleto;
      String fechaRegistro = _formatearFecha(cliente['created_at']?.toString());
      String dirCompleta = '${cliente['direccion'] ?? ''} ${cliente['colonia'] ?? ''}'.trim();
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: filaActual)).value = TextCellValue(idCorto);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: filaActual)).value = TextCellValue(fechaRegistro);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: filaActual)).value = TextCellValue(cliente['nombre']?.toString() ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: filaActual)).value = TextCellValue(cliente['telefono']?.toString() ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: filaActual)).value = TextCellValue(dirCompleta);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: filaActual)).value = TextCellValue(cliente['estado']?.toString() ?? '');
      
      filaActual++;
    }

    // 6. Descarga directa
    var fileBytes = excel.save();
    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: 'Reporte_Clientes.xlsx',
        bytes: Uint8List.fromList(fileBytes),
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // EXPORTAR A PDF (Se mantiene nítido)
  // ─────────────────────────────────────────────────────────
  Future<void> _exportarPDF() async {
    final pdf = pw.Document();

    final tableData = datosFiltrados.map((cliente) {
      String idCorto = cliente['id'].toString().length > 8 
          ? '${cliente['id'].toString().substring(0, 8)}...' 
          : cliente['id'].toString();
      String fechaRegistro = _formatearFecha(cliente['created_at']?.toString());
      String dirCompleta = '${cliente['direccion'] ?? ''} ${cliente['colonia'] ?? ''}'.trim();
      
      return [
        idCorto,
        fechaRegistro,
        cliente['nombre']?.toString() ?? '',
        cliente['telefono']?.toString() ?? '',
        dirCompleta,
        cliente['estado']?.toString() ?? ''
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Reporte de Clientes - EcoRecolector', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  pw.Text('Total: ${datosFiltrados.length}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ]
              )
            ),
            pw.SizedBox(height: 10),
            
            pw.TableHelper.fromTextArray(
              headers: ['ID', 'Fecha', 'Nombre', 'Teléfono', 'Dirección', 'Estado'],
              data: tableData,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
            )
          ];
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: 'Reporte_Clientes.pdf',
      bytes: pdfBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reportes del Sistema',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _exportarExcel,
                    icon: const Icon(Icons.table_view, size: 18),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _exportarPDF,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, fecha o ID...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _filtroEstado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos los estados')),
                      DropdownMenuItem(value: 'Activo', child: Text('Solo Activos')),
                      DropdownMenuItem(value: 'Inactivo', child: Text('Solo Inactivos')),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          _filtroEstado = valor;
                          _aplicarFiltros();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Theme(
                        data: Theme.of(context).copyWith(cardColor: Colors.white, dividerColor: const Color(0xFFEEEEEE)),
                        child: PaginatedDataTable(
                          header: Text('Registros Encontrados: ${datosFiltrados.length}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          rowsPerPage: 6,
                          columnSpacing: 40,
                          horizontalMargin: 24,
                          columns: const [
                            DataColumn(label: Text('ID Registro', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF424242)))),
                            DataColumn(label: Text('Fecha de Registro', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF424242)))),
                            DataColumn(label: Text('Nombre del Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF424242)))),
                            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF424242)))),
                          ],
                          source: _ReportesDataSource(datosFiltrados, _formatearFecha),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> datos;
  final String Function(String?) formateadorFecha;
  
  _ReportesDataSource(this.datos, this.formateadorFecha);

  Widget _buildBadge(String estado) {
    final bool esActivo = estado.toLowerCase() == 'activo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: esActivo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: esActivo ? Colors.green : Colors.red, width: 1),
      ),
      child: Text(estado, style: TextStyle(color: esActivo ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  DataRow? getRow(int index) {
    if (index >= datos.length) return null;
    final fila = datos[index];
    String idCompleto = fila['id'].toString();
    String idCorto = idCompleto.length > 8 ? '${idCompleto.substring(0, 8)}...' : idCompleto;
    
    String fechaRegistro = formateadorFecha(fila['created_at']?.toString());

    return DataRow(
      cells: [
        DataCell(Tooltip(message: idCompleto, child: Text(idCorto, style: const TextStyle(color: Colors.grey, fontFamily: 'monospace', fontWeight: FontWeight.w600)))),
        DataCell(Text(fechaRegistro, style: const TextStyle(color: Color(0xFF616161), fontWeight: FontWeight.w500))),
        DataCell(Text(fila['nombre']?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(_buildBadge(fila['estado']?.toString() ?? 'N/A')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => datos.length;
  @override
  int get selectedRowCount => 0;
}