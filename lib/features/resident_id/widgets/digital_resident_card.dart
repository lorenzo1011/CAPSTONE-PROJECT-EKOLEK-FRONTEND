import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../models/digital_resident_id.dart';
import '../models/resident_id_status.dart';

class DigitalResidentCard extends StatefulWidget {
  const DigitalResidentCard({super.key, required this.id});

  final DigitalResidentId id;

  @override
  State<DigitalResidentCard> createState() => _DigitalResidentCardState();
}

class _DigitalResidentCardState extends State<DigitalResidentCard> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    return Semantics(
      label:
          '${id.fullName}, resident ID ${id.residentId}, ${id.status.label}. '
          '${_showBack ? 'Back' : 'Front'} of official resident card.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official ID Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Generated from your verified backend record',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusPill(status: id.status),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FaceButton(
                    label: 'Front',
                    icon: Icons.badge_outlined,
                    selected: !_showBack,
                    onTap: () => setState(() => _showBack = false),
                  ),
                ),
                Expanded(
                  child: _FaceButton(
                    label: 'Back',
                    icon: Icons.article_outlined,
                    selected: _showBack,
                    onTap: () => setState(() => _showBack = true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: .975, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: AspectRatio(
                key: ValueKey(_showBack),
                aspectRatio: 1011 / 639,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _showBack
                      ? const _OfficialCardBack()
                      : _OfficialCardFront(id: id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Identity fields are read-only and supplied by E-KOLEK.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfficialCardFront extends StatelessWidget {
  const _OfficialCardFront({required this.id});

  final DigitalResidentId id;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final u = w / 100;
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backgrounds/resident_id_front.png',
              ),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x26052D1B),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: w * .212,
                left: w * .354,
                width: w * .555,
                child: Column(
                  children: [
                    Text(
                      'E-KOLEK RESIDENT ID',
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFF084326),
                        fontSize: u * 2.65,
                        fontWeight: FontWeight.w900,
                        letterSpacing: u * .12,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: u * .7),
                    Text(
                      'CITY ENVIRONMENT AND NATURAL RESOURCES OFFICE',
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFF4D6C5A),
                        fontSize: u * 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: u * .10,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: w * .333,
                left: w * .0825,
                width: w * .2065,
                height: w * .211,
                child: _ResidentPhoto(url: id.profilePhotoUrl),
              ),
              Positioned(
                top: w * .313,
                left: w * .363,
                width: w * .53,
                height: w * .064,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: u * 2.1),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      id.fullName.toUpperCase(),
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: u * 3,
                        fontWeight: FontWeight.w900,
                        letterSpacing: u * .04,
                        height: 1,
                        shadows: const [
                          Shadow(
                            color: Color(0x45000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _PositionedField(
                left: .362,
                top: .455,
                width: .39,
                label: 'Resident ID Number',
                value: id.residentId,
                emphasized: true,
                unit: u,
                cardWidth: w,
              ),
              _PositionedField(
                left: .362,
                top: .565,
                width: .39,
                label: 'Barangay',
                value: id.barangayName,
                unit: u,
                cardWidth: w,
              ),
              _PositionedField(
                left: .362,
                top: .675,
                width: .18,
                label: 'ID Card Number',
                value: id.cardNumber ?? 'Pending',
                unit: u,
                cardWidth: w,
              ),
              _PositionedField(
                left: .565,
                top: .675,
                width: .19,
                label: 'Date Issued',
                value: _date(id.cardIssuedAt),
                unit: u,
                cardWidth: w,
              ),
              _PositionedField(
                left: .362,
                top: .785,
                width: .39,
                label: 'Valid Until',
                value: _date(id.cardExpiryDate),
                unit: u,
                cardWidth: w,
              ),
              Positioned(
                top: w * .488,
                left: w * .763,
                width: w * .185,
                child: Column(
                  children: [
                    Container(
                      width: w * .185,
                      height: w * .185,
                      padding: EdgeInsets.all(u * 1.1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(u * 1.55),
                        border: Border.all(
                          color: const Color(0x290B5A34),
                          width: (u * .16).clamp(.5, 2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x1F052D1B),
                            blurRadius: u * 2.5,
                            offset: Offset(0, u * 1.2),
                          ),
                        ],
                      ),
                      child: id.canDisplayQr
                          ? QrImageView(
                              data: id.qrPayload!,
                              padding: EdgeInsets.zero,
                              version: QrVersions.auto,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                              gapless: true,
                              backgroundColor: Colors.white,
                            )
                          : Icon(
                              Icons.qr_code_2_rounded,
                              color: const Color(0xFF8BA397),
                              size: u * 7,
                            ),
                    ),
                    SizedBox(height: u * .75),
                    Text(
                      id.canDisplayQr ? 'SCAN TO VERIFY' : 'QR UNAVAILABLE',
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFF084326),
                        fontSize: u,
                        fontWeight: FontWeight.w900,
                        letterSpacing: u * .11,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: w * .773,
                left: w * .0825,
                width: w * .2065,
                child: Column(
                  children: [
                    Container(
                      height: (u * .13).clamp(.5, 2),
                      color: const Color(0x80084326),
                    ),
                    SizedBox(height: u * .58),
                    Text(
                      'RESIDENT SIGNATURE',
                      style: TextStyle(
                        color: const Color(0xFF416650),
                        fontSize: u * .8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: u * .13,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: w * .358,
                bottom: w * .051,
                child: Text(
                  'OFFICIAL RESIDENT IDENTIFICATION CARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: u * .95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: u * .10,
                    shadows: const [
                      Shadow(color: Color(0x85000000), blurRadius: 2),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: w * .062,
                bottom: w * .0425,
                child: Row(
                  children: [
                    _MiniLogo(
                      asset:
                          'assets/images/branding/Seal_of_San_Pedro,_Laguna.png',
                      size: u * 5.1,
                    ),
                    SizedBox(width: u * .9),
                    _MiniLogo(
                      asset: 'assets/images/branding/cenrologo.png',
                      size: u * 5.1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _date(DateTime? value) => value == null
      ? 'Not set'
      : DateFormat('MMMM d, y').format(value.toLocal());
}

class _OfficialCardBack extends StatelessWidget {
  const _OfficialCardBack();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final u = w / 100;
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backgrounds/resident_id_back.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: w * .183,
                left: w * .23,
                width: w * .54,
                child: Column(
                  children: [
                    Text(
                      'CITY ENVIRONMENT AND NATURAL RESOURCES OFFICE',
                      style: _backStyle(
                        u,
                        .75,
                        const Color(0xFF587365),
                        letterSpacing: .15,
                      ),
                    ),
                    SizedBox(height: u * .55),
                    Text(
                      'E-KOLEK RESIDENT ID',
                      style: _backStyle(
                        u,
                        2.85,
                        const Color(0xFF084326),
                        letterSpacing: .11,
                      ),
                    ),
                    SizedBox(height: u * .72),
                    Text(
                      'OFFICIAL TERMS AND RESIDENT GUIDELINES',
                      style: _backStyle(
                        u,
                        .98,
                        const Color(0xFF60776A),
                        letterSpacing: .11,
                      ),
                    ),
                    SizedBox(height: u * .9),
                    Container(
                      width: u * 9.2,
                      height: (u * .25).clamp(1, 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B5A34), Color(0xFF6FBF73)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: w * .345,
                left: w * .066,
                width: w * .62,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 122,
                      child: _BackCopySection(
                        unit: u,
                        number: '01',
                        title: 'Terms and Conditions',
                        lines: const [
                          'Issued only to a registered E-KOLEK resident of San Pedro City.',
                          'This card remains the property of CENRO San Pedro City.',
                          'Use only for official collections, points and rewards.',
                          'Tampering or unauthorized use may cancel this card.',
                        ],
                      ),
                    ),
                    SizedBox(width: u * 2.2),
                    Container(
                      width: (u * .12).clamp(.5, 2),
                      height: w * .25,
                      color: const Color(0x40084326),
                    ),
                    SizedBox(width: u * 2.2),
                    Expanded(
                      flex: 90,
                      child: _BackCopySection(
                        unit: u,
                        number: '02',
                        title: 'Resident Responsibilities',
                        lines: const [
                          'Present this card during official E-KOLEK transactions.',
                          'Allow authorized personnel to scan the QR for verification.',
                          'Keep this card secure and never lend or transfer it.',
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: w * .345,
                right: w * .058,
                width: w * .23,
                child: Column(
                  children: [
                    _BackSideSection(
                      unit: u,
                      label: 'Digital Verification',
                      title: 'Scan Before Accepting',
                      text:
                          'Accept only when the verified resident status is ACTIVE and matches the cardholder.',
                      showStatus: true,
                    ),
                    SizedBox(height: u * 2.2),
                    _BackSideSection(
                      unit: u,
                      label: 'Security Reminder',
                      title: 'Non-Transferable',
                      text:
                          'This card must only be used by the registered resident.',
                    ),
                  ],
                ),
              ),
              Positioned(
                top: w * .685,
                left: w * .066,
                width: w * .62,
                child: Container(
                  padding: EdgeInsets.only(top: u),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0x40084326))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '!',
                            style: TextStyle(
                              color: const Color(0xFF9A6415),
                              fontSize: u * 1.35,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: u * .85),
                          Text(
                            'LOST, STOLEN OR DAMAGED CARD',
                            style: _backStyle(
                              u,
                              1.12,
                              const Color(0xFF684710),
                              letterSpacing: .08,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: u * .55),
                      Text(
                        'Report lost, stolen or damaged cards immediately to CENRO for deactivation and replacement.',
                        maxLines: 2,
                        style: TextStyle(
                          color: const Color(0xFF504832),
                          fontSize: u * .98,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: w * .785,
                left: w * .066,
                width: w * .59,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CENRO SAN PEDRO CITY CONTACT INFORMATION',
                      style: _backStyle(
                        u,
                        .76,
                        const Color(0xFF5B7164),
                        letterSpacing: .14,
                      ),
                    ),
                    SizedBox(height: u * .35),
                    Text(
                      'Contact CENRO through the official City of San Pedro channels.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF084326),
                        fontSize: u * 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static TextStyle _backStyle(
    double unit,
    double size,
    Color color, {
    double letterSpacing = 0,
  }) => TextStyle(
    color: color,
    fontSize: unit * size,
    fontWeight: FontWeight.w900,
    letterSpacing: unit * letterSpacing,
    height: 1,
  );
}

class _PositionedField extends StatelessWidget {
  const _PositionedField({
    required this.left,
    required this.top,
    required this.width,
    required this.label,
    required this.value,
    required this.unit,
    required this.cardWidth,
    this.emphasized = false,
  });

  final double left;
  final double top;
  final double width;
  final String label;
  final String value;
  final double unit;
  final double cardWidth;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: cardWidth * left,
      top: cardWidth * top,
      width: cardWidth * width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            style: TextStyle(
              color: const Color(0xFF668072),
              fontSize: unit,
              fontWeight: FontWeight.w900,
              letterSpacing: unit * .10,
              height: 1,
            ),
          ),
          SizedBox(height: unit * .48),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasized
                  ? const Color(0xFF0B5A34)
                  : const Color(0xFF0A3722),
              fontSize: unit * (emphasized ? 2.12 : 1.95),
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentPhoto extends StatelessWidget {
  const _ResidentPhoto({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: const Color(0xFFF0F6F2),
      child: LayoutBuilder(
        builder: (context, constraints) => Icon(
          Icons.person_rounded,
          size: constraints.maxWidth * .5,
          color: const Color(0xFF789481),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null
          ? fallback
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 220),
              placeholder: (_, _) => const ColoredBox(
                color: Color(0xFFF0F6F2),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0B5A34),
                  ),
                ),
              ),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}

class _BackCopySection extends StatelessWidget {
  const _BackCopySection({
    required this.unit,
    required this.number,
    required this.title,
    required this.lines,
  });

  final double unit;
  final String number;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            color: const Color(0xFF0B5A34),
            fontSize: unit * .85,
            fontWeight: FontWeight.w900,
            letterSpacing: unit * .14,
          ),
        ),
        SizedBox(height: unit * .42),
        Text(
          title.toUpperCase(),
          maxLines: 1,
          style: TextStyle(
            color: const Color(0xFF084326),
            fontSize: unit * 1.4,
            fontWeight: FontWeight.w900,
            letterSpacing: unit * .05,
            height: 1,
          ),
        ),
        SizedBox(height: unit * .72),
        Container(
          width: double.infinity,
          height: (unit * .1).clamp(.5, 2),
          color: const Color(0x50084326),
        ),
        SizedBox(height: unit * .72),
        ...lines.map(
          (line) => Padding(
            padding: EdgeInsets.only(bottom: unit * .68),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: unit * .5,
                  height: unit * .5,
                  margin: EdgeInsets.only(top: unit * .35),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B5A34),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: unit * .7),
                Expanded(
                  child: Text(
                    line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF244334),
                      fontSize: unit * .95,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BackSideSection extends StatelessWidget {
  const _BackSideSection({
    required this.unit,
    required this.label,
    required this.title,
    required this.text,
    this.showStatus = false,
  });

  final double unit;
  final String label;
  final String title;
  final String text;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: unit * 1.3),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFF0B5A34),
            width: (unit * .3).clamp(1, 4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF0B5A34),
              fontSize: unit * .76,
              fontWeight: FontWeight.w900,
              letterSpacing: unit * .12,
            ),
          ),
          SizedBox(height: unit * .45),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF084326),
              fontSize: unit * 1.35,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          SizedBox(height: unit * .65),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF2B493A),
              fontSize: unit,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (showStatus) ...[
            SizedBox(height: unit * .8),
            Row(
              children: [
                Container(
                  width: unit * .65,
                  height: unit * .65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34A853),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34A853).withValues(alpha: .18),
                        spreadRadius: unit * .3,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: unit * .6),
                Text(
                  'VERIFY RESIDENT STATUS',
                  style: TextStyle(
                    color: const Color(0xFF084326),
                    fontSize: unit * .78,
                    fontWeight: FontWeight.w900,
                    letterSpacing: unit * .05,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniLogo extends StatelessWidget {
  const _MiniLogo({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .06),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x1F0B5A34)),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF0B5A34) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ResidentIdStatus status;

  @override
  Widget build(BuildContext context) {
    final active = status == ResidentIdStatus.active;
    final foreground = active ? AppColors.success : AppColors.warning;
    final background = active
        ? AppColors.successContainer
        : AppColors.warningContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
