import 'package:flutter/material.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amerli_app/core/config/injection.dart' as di;
import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/features/auth/domain/repositories/profile_repository.dart';
import 'package:amerli_app/utils/constants/app_constants.dart';
import 'dart:math' as math;

import 'invoice_detail_page.dart';
import 'package:amerli_app/core/utils/top_toast.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  static const Color _darkGreen = Color(0xFF083B2E);
  static const Color _primary = Color(0xFFA7C957);

  // Real invoice data (populated from backend)
  final List<Map<String, String?>> _items = [];
  bool _isLoading = false;

  // Pagination state
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasNextPage) {
        _loadMoreInvoices();
      }
    }
  }

  Future<void> _fetchInvoices({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      // Fetch current user id from ProfileRepository
      final profileRepo = di.sl<ProfileRepository>();
      await profileRepo.fetchProfile();

      // Call backend to get invoices for current user with pagination
      final api = di.sl<ApiService>();
      final page = loadMore ? _currentPage + 1 : 1;
      final resp = await api
          .get('/invoices/user/', queryParameters: {'page': page, 'limit': 10});

      if (resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300 &&
          resp.data != null) {
        final responseData = resp.data as Map<String, dynamic>;

        // Extract meta data for pagination
        final meta = responseData['meta'] as Map<String, dynamic>?;
        if (meta != null) {
          _hasNextPage = meta['hasNextPage'] as bool? ?? false;
          _currentPage = meta['page'] as int? ?? page;
        }

        // Extract data array
        final list = responseData['data'] as List<dynamic>? ?? [];
        final host = AppConstants.apiBaseUrl.replaceFirst('/api/v1', '');
        final parsed = list.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final id =
              m['id']?.toString() ?? m['invoiceNumber']?.toString() ?? '';
          String created = '';
          try {
            final rawDate = m['createdAt']?.toString() ??
                m['created_at']?.toString() ??
                m['date']?.toString();
            if (rawDate != null && rawDate.isNotEmpty) {
              final dt = DateTime.parse(rawDate);
              created =
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
            }
          } catch (_) {
            created = m['createdAt']?.toString() ??
                m['created_at']?.toString() ??
                m['date']?.toString() ??
                '';
          }
          final pdf = m['pdfUrl']?.toString() ??
              '$host/api/v1/invoices/${m['id']}/download';
          return {'id': id, 'date': created, 'pdf': pdf};
        }).toList();

        setState(() {
          if (loadMore) {
            _items.addAll(parsed.cast<Map<String, String?>>());
          } else {
            _items.clear();
            _items.addAll(parsed.cast<Map<String, String?>>());
          }
        });
      } else {
        // leave empty or show message
      }
    } catch (e) {
      if (!mounted) return;
      TopToast.show(
        context,
        'Failed to load invoices: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreInvoices() async {
    await _fetchInvoices(loadMore: true);
  }

  final Set<String> _selected = {};

  Widget _buildCheckbox(
      {required bool value, required ValueChanged<bool?> onChanged}) {
    // A circular-ish 28x28 checkbox with no visible native border and layered shadows
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? _primary : Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 1),
          BoxShadow(
              color: Color(0x29676E76),
              offset: Offset(0, 0),
              blurRadius: 0,
              spreadRadius: 1),
          BoxShadow(
              color: Color(0x14676E76), offset: Offset(0, 2), blurRadius: 5),
        ],
      ),
      alignment: Alignment.center,
      child: Theme(
        data: Theme.of(context)
            .copyWith(unselectedWidgetColor: Colors.transparent),
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

  Future<void> _openPdf(String? pdf) async {
    if (pdf == null) {
      if (!mounted) return;
      TopToast.show(context, AppLanguage.noPdfAvailable, isError: true);
      return;
    }
    final uri = Uri.parse(pdf);
    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    TopToast.show(context, AppLanguage.pdfDownloadError, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    // Table text styles (slightly reduced for better fit)
    final tableHeaderStyle = const TextStyle(
        color: _darkGreen, fontWeight: FontWeight.w700, fontSize: 13);
    final tableBodyIdStyle = const TextStyle(
        fontWeight: FontWeight.w700, color: Color(0xFF333333), fontSize: 13);
    final tableBodyDateStyle =
        const TextStyle(color: Colors.grey, fontSize: 12);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top app-bar like row: back button + centered title
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 16,
                          height: 16,
                          matchTextDirection: true,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                          placeholderBuilder: (context) => Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Text(
                          AppLanguage.myInvoices,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // balance spacing with an invisible box same as back button
                    const SizedBox(width: 40, height: 40),
                  ],
                ),
              ),
            ),

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
                    BoxShadow(
                        color: Color(0x1F000000),
                        offset: Offset(0, 1),
                        blurRadius: 1),
                    BoxShadow(
                        color: Color(0x29676E76),
                        offset: Offset(0, 0),
                        blurRadius: 0,
                        spreadRadius: 1),
                    BoxShadow(
                        color: Color(0x14676E76),
                        offset: Offset(0, 2),
                        blurRadius: 5),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: Column(
                  children: [
                    // Header row (checkbox | ID Commande | Date de Facture | Actions)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          // Select-all checkbox aligned with the row checkboxes
                          SizedBox(
                              width: 30,
                              child: Center(
                                  child: _buildCheckbox(
                                value: _selected.length == _items.length &&
                                    _items.isNotEmpty,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selected
                                          .addAll(_items.map((e) => e['id']!));
                                    } else {
                                      _selected.clear();
                                    }
                                  });
                                },
                              ))),

                          // ID column (expandable)
                          Expanded(
                            child: Text(
                              AppLanguage.orderId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tableHeaderStyle,
                            ),
                          ),

                          // Date column (fixed width)
                          SizedBox(
                              width: 120,
                              child: Text(AppLanguage.invoiceDate,
                                  style: tableHeaderStyle)),

                          // Actions column (narrower)
                          SizedBox(
                              width: 72,
                              child: Text(AppLanguage.actions,
                                  textAlign: TextAlign.right,
                                  style: tableHeaderStyle)),
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
                        final maxListHeight = math.min(
                            MediaQuery.of(context).size.height * 0.65,
                            56.0 * _items.length + 40.0 + bottomPadding);
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxListHeight),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    children: [
                                      Expanded(
                                        child: ListView.separated(
                                          controller: _scrollController,
                                          shrinkWrap: true,
                                          itemCount: _items.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 6),
                                          itemBuilder: (context, index) {
                                            final item = _items[index];
                                            final id = item['id']!;
                                            return SizedBox(
                                              height: 56,
                                              child: Row(
                                                children: [
                                                  // checkbox column (narrow)
                                                  SizedBox(
                                                      width: 44,
                                                      child: Center(
                                                          child: _buildCheckbox(
                                                        value: _selected
                                                            .contains(id),
                                                        onChanged: (v) =>
                                                            setState(() => v!
                                                                ? _selected
                                                                    .add(id)
                                                                : _selected
                                                                    .remove(
                                                                        id)),
                                                      ))),

                                                  // ID column (expandable)
                                                  Expanded(
                                                    child: Text(id,
                                                        style: tableBodyIdStyle,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),

                                                  // Date column (fixed)
                                                  SizedBox(
                                                      width: 120,
                                                      child: Text(
                                                          item['date'] ?? '-',
                                                          style:
                                                              tableBodyDateStyle)),

                                                  // Actions (narrow with reduced spacing)
                                                  SizedBox(
                                                    width: 72,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () => _openPdf(
                                                              item['pdf']),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: Container(
                                                            width: 32,
                                                            height: 32,
                                                            alignment: Alignment
                                                                .center,
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/icons/download.svg',
                                                              width: 18,
                                                              height: 18,
                                                              colorFilter:
                                                                  const ColorFilter
                                                                      .mode(
                                                                      _darkGreen,
                                                                      BlendMode
                                                                          .srcIn),
                                                              placeholderBuilder:
                                                                  (_) => const Icon(
                                                                      Icons
                                                                          .download,
                                                                      color:
                                                                          _darkGreen,
                                                                      size: 18),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        InkWell(
                                                          onTap: () => Navigator
                                                                  .of(context)
                                                              .push(MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      InvoiceDetailPage(
                                                                          invoiceId:
                                                                              id,
                                                                          pdfUrl:
                                                                              item['pdf']))),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: Container(
                                                            width: 32,
                                                            height: 32,
                                                            alignment: Alignment
                                                                .center,
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/icons/visible.svg',
                                                              width: 18,
                                                              height: 18,
                                                              colorFilter:
                                                                  const ColorFilter
                                                                      .mode(
                                                                      _darkGreen,
                                                                      BlendMode
                                                                          .srcIn),
                                                              placeholderBuilder:
                                                                  (_) => const Icon(
                                                                      Icons
                                                                          .remove_red_eye,
                                                                      color:
                                                                          _darkGreen,
                                                                      size: 18),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (_isLoadingMore)
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                    ],
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
