import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/data/repositories/support_repository.dart';
import 'package:essivi_mobile/data/models/faq_models.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _supportRepo = SupportRepository();
  List<FAQ> _faqs = [];
  List<FAQ> _filteredFaqs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    setState(() => _isLoading = true);
    try {
      _faqs = await _supportRepo.getFAQs();
      _filteredFaqs = _faqs;
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterFAQs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFaqs = _faqs;
      } else {
        _filteredFaqs = _faqs.where((faq) {
          return faq.question.toLowerCase().contains(query.toLowerCase()) ||
                 faq.answer.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.helpCenter,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rechercher Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une question...',
                          border: InputBorder.none,
                          icon: Icon(FluentIcons.search_24_regular, color: theme.textTheme.bodySmall?.color),
                          hintStyle: GoogleFonts.poppins(color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // FAQ Section
                    Text(
                      'Questions Fréquentes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_filteredFaqs.isEmpty)
                      Center(
                        child: Text(
                          'Aucune FAQ trouvée',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    else
                      ..._filteredFaqs.map((faq) => _buildFAQItem(context, faq.question, faq.answer)),
                    const SizedBox(height: 24),

                    // Contact Support
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, const Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(FluentIcons.chat_help_24_filled, color: Colors.white, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Besoin d\'aide ?',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nontre équipe est disponible 24/7',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showContactDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Contacter le Support',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showContactDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nous Contacter',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(FluentIcons.mail_24_regular, color: theme.primaryColor),
              title: Text('Email', style: GoogleFonts.poppins()),
              subtitle: Text('support@essivi.com', style: GoogleFonts.poppins(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              onTap: () {
                Navigator.pop(context);
                // Launch email app
              },
            ),
            ListTile(
              leading: Icon(FluentIcons.phone_24_regular, color: theme.primaryColor),
              title: Text('Téléphone 1', style: GoogleFonts.poppins()),
              subtitle: Text('+228 97254050', style: GoogleFonts.poppins(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              onTap: () {
                Navigator.pop(context);
                // Launch phone dialer
              },
            ),
            ListTile(
              leading: Icon(FluentIcons.phone_24_regular, color: theme.primaryColor),
              title: Text('Téléphone 2', style: GoogleFonts.poppins()),
              subtitle: Text('+228 70 66 58 17', style: GoogleFonts.poppins(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              onTap: () {
                Navigator.pop(context);
                // Launch phone dialer
              },
            ),
            ListTile(
              leading: Icon(FluentIcons.chat_24_regular, color: theme.primaryColor),
              title: Text('WhatsApp 1', style: GoogleFonts.poppins()),
              subtitle: Text('+228 70 66 58 17', style: GoogleFonts.poppins(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              onTap: () {
                Navigator.pop(context);
                // Launch WhatsApp
              },
            ),
            ListTile(
              leading: Icon(FluentIcons.chat_24_regular, color: theme.primaryColor),
              title: Text('WhatsApp 2', style: GoogleFonts.poppins()),
              subtitle: Text('+228 97254050', style: GoogleFonts.poppins(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              onTap: () {
                Navigator.pop(context);
                // Launch WhatsApp
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: GoogleFonts.poppins(color: theme.primaryColor)),
          ),
        ],
      ),
    );
  }
}
