import 'package:flutter/material.dart';
import 'package:self_finance/theme/app_colors.dart';



class Fab extends StatelessWidget {
  const Fab({super.key, this.heroTag,required this.onPressed, required this.icon});
  final String? heroTag;
  final void Function()? onPressed;
  final IconData icon; 

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: onPressed,
      heroTag: heroTag,
    backgroundColor: AppColors.getPrimaryColor,
    child: Icon(icon,)
    ); 
  }
}




