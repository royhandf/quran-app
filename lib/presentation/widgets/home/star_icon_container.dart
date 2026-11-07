import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Wadah ikon 44x44 berbentuk bintang dari `wadah-ikon-bintang.svg`.
/// Warna wadah diganti lewat [containerColor]; ikon di tengah lewat [iconColor].
class StarIconContainer extends StatelessWidget {
  final IconData icon;
  final Color containerColor;
  final Color iconColor;
  final double size;

  const StarIconContainer({
    super.key,
    required this.icon,
    required this.containerColor,
    required this.iconColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/wadah-ikon-bintang.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(containerColor, BlendMode.srcIn),
          ),
          Icon(icon, size: size * 0.45, color: iconColor),
        ],
      ),
    );
  }
}
