import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import 'invoice_detail_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  static const Color _darkGreen = Color(0xFF083B2E);
  static const Color _primary = Color(0xFFA7C957);

  // Mock invoice data
  final List<Map<String, String?>> _items = [
    {'id': 'CMD-2025-001', 'date': '2025-01-02', 'pdf': 'https://www.example.com/invoice1.pdf'},
    {'id': 'CMD-2025-002', 'date': '2025-02-10', 'pdf': 'https://www.example.com/invoice2.pdf'},
    {'id': 'CMD-2025-003', 'date': '2025-03-18', 'pdf': null},
  ];

  final Set<String> _selected = {};

  Widget _buildCheckbox({required bool value, required ValueChanged<bool?> onChanged}) {
    // A circular-ish 28x28 checkbox with no visible native border and layered shadows
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: value ? _primary : Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 1),
          BoxShadow(color: Color(0x29676E76), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1),
          BoxShadow(color: Color(0x14676E76), offset: Offset(0, 2), blurRadius: 5),
        ],
      ),
      alignment: Alignment.center,
      child: Theme(
        data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.transparent),
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.transparent,
          checkColor: Colors.white,
          side: BorderSide.none,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context, String? pdf) async {
    if (pdf == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun PDF disponible')));
      return;
    }
    final uri = Uri.parse(pdf);
    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de télécharger le PDF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Container sized to content with a reasonable max height
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // make edges more rounded
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primary),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 1),
                    BoxShadow(color: Color(0x29676E76), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1),
                    BoxShadow(color: Color(0x14676E76), offset: Offset(0, 2), blurRadius: 5),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  children: [
                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          // Select-all checkbox aligned with the row checkboxes
                          SizedBox(width: 36, child: Center(child: _buildCheckbox(
                            value: _selected.length == _items.length && _items.isNotEmpty,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selected.addAll(_items.map((e) => e['id']!));
                                } else {
                                  _selected.clear();
                                }
                              });
                            },
                          ))),

                          // Keep header text in a single line and ellipsize if needed
                          const Expanded(
                            child: Text(
                              'ID Commande',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: _darkGreen, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 120, child: Text('Date de Facture', style: TextStyle(color: _darkGreen, fontWeight: FontWeight.w700, fontSize: 14))),
                          const SizedBox(width: 90, child: Text('Actions', textAlign: TextAlign.right, style: TextStyle(color: _darkGreen, fontWeight: FontWeight.w700, fontSize: 14))),
                        ],
                      ),
                    ),

                    // first divider should be primary and full width
                    Divider(height: 1, color: _primary, thickness: 1),
                    const SizedBox(height: 6),

                    // Size the list to its content but cap it to a portion of the
                    // screen height so it doesn't take the whole page. Add bottom padding
                    Builder(
                      builder: (context) {
                        const double bottomPadding = 8.0;
                        final maxListHeight = math.min(MediaQuery.of(context).size.height * 0.65, 56.0 * _items.length + 40.0 + bottomPadding);
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxListHeight),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final id = item['id']!;
                                return SizedBox(
                                  height: 56,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 36, child: Center(child: _buildCheckbox(
                                        value: _selected.contains(id),
                                        onChanged: (v) => setState(() => v! ? _selected.add(id) : _selected.remove(id)),
                                      ))),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(id, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                                            const SizedBox(height: 4),
                                            Text(item['date']!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => _openPdf(context, item['pdf']),
                                            borderRadius: BorderRadius.circular(24),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.download, color: _darkGreen),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          InkWell(
                                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoiceDetailPage(invoiceId: id, pdfUrl: item['pdf']))),
                                            borderRadius: BorderRadius.circular(24),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.visibility, color: _darkGreen),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
