import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/presentation/widgets/cards/compact_order_card.dart';
import 'package:essivi_mobile/presentation/widgets/feedback/empty_state.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AgentHistoryScreen extends StatefulWidget {
  const AgentHistoryScreen({super.key});

  @override
  State<AgentHistoryScreen> createState() => _AgentHistoryScreenState();
}

class _AgentHistoryScreenState extends State<AgentHistoryScreen> {
  final _authRepo = AuthRepository();
  final _salesRepo = SalesRepository();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final user = await _authRepo.getCurrentUser();
      final orders = await _salesRepo.getCommandesByAgent(user.id);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Historique des livraisons'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_orders.isEmpty
                ? const EmptyState(
                    title: 'Aucune livraison',
                    message: 'Votre historique apparaîtra ici.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return CompactOrderCard(
                        orderId: order.id.toString(),
                        status: order.statut,
                        date: order.createdAt.substring(0, 10),
                        amount: order.montant,
                        onTap: () {},
                      );
                    },
                  )),
    );
  }
}
