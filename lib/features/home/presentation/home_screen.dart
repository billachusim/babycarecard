import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_providers.dart';
import '../../../core/theme/app_theme.dart';

import '../../premium/presentation/premium_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _onAddChildPressed(
    BuildContext context,
    WidgetRef ref,
    int currentChildCount, {
    bool byVoice = false,
  }) {
    final isPremium = ref.read(premiumNotifierProvider).isPremium;
    if (!isPremium && currentChildCount >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free version includes 1 child. Unlock Premium for unlimited children!'),
        ),
      );
      context.push('/premium');
    } else {
      context.push(byVoice ? '/voice-fill' : '/add-child');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider);
    final childCount = childrenAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Care Card'),
        actions: [
          IconButton(
            onPressed: () => _onAddChildPressed(context, ref, childCount, byVoice: true),
            icon: const Icon(Icons.mic_outlined),
            tooltip: 'Add a child by voice',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: childrenAsync.when(
        data: (children) {
          if (children.isEmpty) {
            return EmptyChildrenState(
              onAddChild: () => _onAddChildPressed(context, ref, 0),
              onAddByVoice: () => _onAddChildPressed(context, ref, 0, byVoice: true),
            );
          }
          return ChildrenList(children: children);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      // The empty state has its own Add Child buttons, so only show this
      // once there's at least one card.
      floatingActionButton: childCount == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _onAddChildPressed(context, ref, childCount),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              label: const Text('Add Child'),
              icon: const Icon(Icons.add),
            ),
    );
  }
}

class EmptyChildrenState extends StatelessWidget {
  final VoidCallback onAddChild;
  final VoidCallback onAddByVoice;
  const EmptyChildrenState({
    super.key,
    required this.onAddChild,
    required this.onAddByVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 32),
          Text(
            'Your child\'s care card starts here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create one for your child before their next stay with a sitter.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: onAddChild,
            icon: const Icon(Icons.add),
            label: const Text('Add Child'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAddByVoice,
            icon: const Icon(Icons.mic_rounded),
            label: const Text('Just say it: add by voice'),
          ),
        ],
      ),
    );
  }
}

class ChildrenList extends StatelessWidget {
  final List children; // List<Child>

  const ChildrenList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => context.push('/care-card/${child.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: child.photoPath != null
                        ? ClipOval(child: Image.network(child.photoPath!, fit: BoxFit.cover, width: 64, height: 64))
                        : const Icon(Icons.child_care, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${child.ageGroup}${child.allergies != null ? " • Allergies: ${child.allergies}" : ""}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
