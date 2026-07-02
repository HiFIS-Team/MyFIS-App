import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/press_fade.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/reward_capsule.dart';

/// 비밀번호 변경 — 현재/새/새 확인 입력 + 유효성. (현재 더미, 서버 연동 시 API 연결)
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  static const int _minLen = 8;

  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool _submitted = false;

  // 성공 캡슐 토스트.
  bool _toastActive = false;
  late final AnimationController _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  bool get _lenOk => _next.text.length >= _minLen;
  bool get _matchOk => _confirm.text.isNotEmpty && _confirm.text == _next.text;
  bool get _valid =>
      _current.text.isNotEmpty && _lenOk && _matchOk && !_submitted;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    _toast.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() {
      _submitted = true;
      _toastActive = true;
    });
    _toast.forward(from: 0);
    // (더미) 성공 표시 후 뒤로
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mismatch = _confirm.text.isNotEmpty && _confirm.text != _next.text;

    return Scaffold(
      appBar: const AppTopBar(title: '비밀번호 변경'),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('현재 비밀번호'),
                  _PasswordField(
                    controller: _current,
                    hint: '현재 비밀번호를 입력하세요',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 22),

                  _Label('새 비밀번호'),
                  _PasswordField(
                    controller: _next,
                    hint: '새 비밀번호를 입력하세요',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  _Hint(
                    text: '$_minLen자 이상 입력해주세요',
                    ok: _lenOk,
                    show: true,
                  ),
                  const SizedBox(height: 22),

                  _Label('새 비밀번호 확인'),
                  _PasswordField(
                    controller: _confirm,
                    hint: '새 비밀번호를 다시 입력하세요',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  if (mismatch)
                    Text(
                      '비밀번호가 일치하지 않아요',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                    )
                  else if (_matchOk)
                    _Hint(text: '비밀번호가 일치해요', ok: true, show: true),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: PressableButton(
                      onPressed: _valid ? _submit : null,
                      child: const Text('변경하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 성공 캡슐
          if (_toastActive)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _toast,
                builder: (context, child) => TopToast(
                  progress: _toast.value,
                  child: child!,
                ),
                child: const Center(
                  child: RewardCapsule(text: '비밀번호가 변경되었어요'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// 라벨 아래 안내/검증 문구 (충족 시 라임 체크).
class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.ok, required this.show});
  final String text;
  final bool ok;
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final color = ok ? AppColors.lime : AppColors.textSecondary;
    return Row(
      children: [
        Icon(ok ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// 비밀번호 입력 필드 — 가림/보기 토글.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              obscureText: _obscure,
              style: Theme.of(context).textTheme.bodyLarge,
              cursorColor: AppColors.lime,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: TextStyle(color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          PressableIcon(
            icon: _obscure ? Symbols.visibility_off : Symbols.visibility,
            size: 22,
            color: AppColors.textSecondary,
            onTap: () => setState(() => _obscure = !_obscure),
          ),
        ],
      ),
    );
  }
}
