import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StarIconContainer extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Color containerColor;
  final Color iconColor;
  final double size;

  const StarIconContainer({
    super.key,
    this.icon,
    this.label,
    required this.containerColor,
    required this.iconColor,
    this.size = 44,
  }) : assert(
         (icon == null) != (label == null),
         'Isi salah satu: icon atau label',
       );

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
          if (icon != null)
            Icon(icon, size: size * 0.45, color: iconColor)
          else
            Text(
              label!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: size * 0.3,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}
