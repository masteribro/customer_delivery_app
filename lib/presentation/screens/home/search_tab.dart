import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/repositories/vendor_repository.dart';
import '../../widgets/vendor_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _searchController = TextEditingController();
  final _vendorRepo = VendorRepository();
  List<VendorModel>? _results;
  bool _isLoading = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    _query = query;
    if (query.trim().length < 2) {
      setState(() => _results = null);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final results = await _vendorRepo.searchVendors(query);
      if (_query == query) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Search field
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _search,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search restaurants, cuisines...',
                prefixIcon: const Icon(Icons.search,
                    size: 22, color: AppColors.textTertiary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 20, color: AppColors.textTertiary),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _results == null
                    ? _buildEmptyState()
                    : _results!.isEmpty
                        ? _buildNoResults()
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _results!.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return VendorCard(
                                vendor: _results![index],
                                onTap: () => context
                                    .push('/vendor/${_results![index].id}'),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded,
              size: 56, color: AppColors.textTertiary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'Search for your favourite\nrestaurants or cuisines',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textTertiary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No results found',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Try a different search term', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
