import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hash_link/blocs/decrypt/decrypt_bloc.dart';
import 'package:hash_link/helpers/file_preview_helper.dart';
import 'package:hash_link/theme/app_colors.dart';
import 'package:hash_link/theme/app_spacing.dart';
import 'package:hash_link/widgets/page_header.dart';
import 'package:hash_link/widgets/section_title.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../widgets/decryption_info_sidebar.dart';
import '../initial/initial_view.dart';
import '../../widgets/custom_toast.dart';
import 'package:flutter/services.dart';

class DecryptView extends StatefulWidget {
  const DecryptView({super.key});

  static const route = '/decrypt';

  @override
  State<DecryptView> createState() => _DecryptViewState();
}

class _DecryptViewState extends State<DecryptView> {
  bool get isSmallScreen => MediaQuery.of(context).size.width < 768;

  @override
  void initState() {
    context.read<DecryptBloc>().add(const ResetDecrypt());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 330,
            child: Column(
              children: [
                const Expanded(
                  child: DecryptionInfoSidebar(),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.grey300,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(InitialView.route),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                            horizontal: AppSpacing.lg,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: AppColors.grey700,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Voltar ao Menu',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.grey700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DecryptBloc, DecryptState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.lg,
                        right: AppSpacing.lg,
                        left: AppSpacing.lg,
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          const SizedBox(height: 185),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: SectionTitle(
                              title: 'Descriptografia de Arquivos',
                              subtitle:
                                  'Importe os arquivos necessários para descriptografar seu pacote',
                              titleStyle: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.grey900,
                                  ),
                              subtitleStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    color: AppColors.grey700,
                                  ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (isSmallScreen) ...[
                            _buildPrivateKeySection(context, Theme.of(context),
                                state, isSmallScreen),
                            const SizedBox(height: AppSpacing.lg),
                            _buildPackageSection(context, Theme.of(context),
                                state, isSmallScreen),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildPrivateKeySection(context,
                                      Theme.of(context), state, isSmallScreen),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: _buildPackageSection(context,
                                      Theme.of(context), state, isSmallScreen),
                                ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.containerMd),
                          _buildDecryptButton(
                              context, state, Theme.of(context)),
                          if (state.decryptedFile != null)
                            _buildResultSection(
                                state, Theme.of(context), isSmallScreen),
                        ],
                      ),
                    ),
                    const Positioned(
                      top: AppSpacing.lg,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: PageHeader(
                        logoPath: 'assets/images/logo.png',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateKeySection(BuildContext context, ThemeData theme,
      DecryptState state, bool isSmallScreen) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: state.privateKey != null
                ? AppColors.success.withOpacity(0.3)
                : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Padding(
          padding:
              EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.key, color: AppColors.primary),
                  SizedBox(
                      width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Chave Privada',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Importe sua chave privada para descriptografar o arquivo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.privateKey != null
                            ? AppColors.success.withOpacity(0.9)
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: state.privateKey != null ? 0 : 2,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      onPressed: state.privateKey != null
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              context
                                  .read<DecryptBloc>()
                                  .add(const SelectPrivateKey());
                            },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          state.privateKey != null
                              ? Icons.check_circle
                              : Icons.key_rounded,
                          key: ValueKey(state.privateKey != null),
                        ),
                      ),
                      label: Text(
                        state.privateKey != null
                            ? 'Chave Importada com Sucesso'
                            : 'Selecionar Chave',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (state.privateKeyError != null ||
                      state.privateKey != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    _buildPrivateKeyStatusIcon(state, theme),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivateKeyStatusIcon(DecryptState state, ThemeData theme) {
    final hasError = state.privateKeyError != null;
    final message = hasError
        ? state.privateKeyError!
        : 'Chave Privada importada com sucesso!';

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1.0,
      child: Tooltip(
        message: message,
        preferBelow: false,
        decoration: BoxDecoration(
          color: hasError
              ? AppColors.error.withOpacity(0.95)
              : AppColors.success.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (hasError ? AppColors.error : AppColors.success)
                  .withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: (hasError ? AppColors.error : AppColors.success)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            hasError ? Icons.error_rounded : Icons.check_circle_rounded,
            color: hasError ? AppColors.error : AppColors.success,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPackageSection(BuildContext context, ThemeData theme,
      DecryptState state, bool isSmallScreen) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: _hasAnyPackageStatus(state)
                ? AppColors.success.withOpacity(0.3)
                : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Padding(
          padding:
              EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_zip, color: AppColors.primary),
                  SizedBox(
                      width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Pacote Criptografado',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Selecione o pacote criptografado que deseja descriptografar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasValidPackageImport(state)
                            ? AppColors.success.withOpacity(0.9)
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: _hasValidPackageImport(state) ? 0 : 2,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      onPressed: _hasValidPackageImport(state)
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              context
                                  .read<DecryptBloc>()
                                  .add(const SelectPackage());
                            },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _hasValidPackageImport(state)
                              ? Icons.check_circle
                              : Icons.folder_zip_rounded,
                          key: ValueKey(_hasValidPackageImport(state)),
                        ),
                      ),
                      label: Text(
                        _hasValidPackageImport(state)
                            ? 'Pacote Importado com Sucesso'
                            : 'Selecionar Pacote',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_hasAnyPackageStatus(state)) ...[
                    const SizedBox(width: AppSpacing.md),
                    _buildPackageStatusIcon(state, theme),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageStatusIcon(DecryptState state, ThemeData theme) {
    final List<String> messages = [];
    bool hasError = false;

    // Verifica dados encriptados
    if (state.dataEncryptedError != null) {
      messages.add('❌ ${state.dataEncryptedError}');
      hasError = true;
    } else if (state.dataEncrypted != null) {
      messages.add('✅ Dados Encriptados importados com sucesso');
    }

    // Verifica chave AES
    if (state.aesKeyError != null) {
      messages.add('❌ ${state.aesKeyError}');
      hasError = true;
    } else if (state.aesKey != null) {
      messages.add('✅ Chave AES importada com sucesso');
    }

    // Verifica assinatura
    if (state.signatureError != null) {
      messages.add('❌ ${state.signatureError}');
      hasError = true;
    } else if (state.signature != null) {
      messages.add('✅ Assinatura importada com sucesso');
    }

    // Verifica chave pública
    if (state.publicKeyError != null) {
      messages.add('❌ ${state.publicKeyError}');
      hasError = true;
    } else if (state.publicKey != null) {
      messages.add('✅ Chave Pública importada com sucesso');
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: 1.0,
      child: Tooltip(
        message: messages.join('\n'),
        preferBelow: false,
        decoration: BoxDecoration(
          color: hasError
              ? AppColors.error.withOpacity(0.95)
              : AppColors.success.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (hasError ? AppColors.error : AppColors.success)
                  .withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: (hasError ? AppColors.error : AppColors.success)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            hasError ? Icons.error_rounded : Icons.check_circle_rounded,
            color: hasError ? AppColors.error : AppColors.success,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDecryptButton(
      BuildContext context, DecryptState state, ThemeData theme) {
    if (state.decryptedFile != null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: state.inputsIsValid ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.4),
            disabledBackgroundColor: AppColors.grey300,
          ),
          onPressed: state.inputsIsValid
              ? () {
                  context.read<DecryptBloc>().add(const DecryptData());
                  CustomToast.show(
                    context,
                    'Arquivo descriptografado com sucesso!',
                    type: ToastType.success,
                  );
                }
              : null,
          icon: const Icon(Icons.lock_open),
          label: const Text(
            'Descriptografar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(
      DecryptState state, ThemeData theme, bool isSmallScreen) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      margin:
          EdgeInsets.only(top: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding:
              EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary),
                  SizedBox(
                      width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Arquivo descriptografado com sucesso!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: state.isSignatureValid
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.isSignatureValid
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isSignatureValid
                          ? Icons.verified_user
                          : Icons.gpp_bad,
                      color: state.isSignatureValid
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        state.isSignatureValid
                            ? 'Assinatura do arquivo é válida!'
                            : 'Assinatura do arquivo não é válida!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: state.isSignatureValid
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                    onPressed: () {
                      FilePreviewHelper.showPreviewModal(
                        context: context,
                        content: state.decryptedFile!,
                        fileName: 'arquivo_descriptografado',
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Visualizar Arquivo'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                    onPressed: () {
                      FilePreviewHelper.saveFile(
                        bytes: Uint8List.fromList(state.decryptedFile!),
                        fileName: 'arquivo_descriptografado',
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Arquivo'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description, color: AppColors.grey700),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tamanho do arquivo: ${state.decryptedFile!.length} bytes',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAnyPackageStatus(DecryptState state) {
    return state.dataEncrypted != null ||
        state.aesKey != null ||
        state.signature != null ||
        state.publicKey != null ||
        state.dataEncryptedError != null ||
        state.aesKeyError != null ||
        state.signatureError != null ||
        state.publicKeyError != null;
  }

  bool _hasValidPackageImport(DecryptState state) {
    return state.dataEncrypted != null &&
        state.aesKey != null &&
        state.signature != null &&
        state.publicKey != null &&
        state.dataEncryptedError == null &&
        state.aesKeyError == null &&
        state.signatureError == null &&
        state.publicKeyError == null;
  }
}