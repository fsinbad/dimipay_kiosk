import 'package:dimipay_design_kit/dimipay_design_kit.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dimipay_kiosk/app/pages/payment/controller.dart';

class BackgroundSpot extends StatelessWidget {
  const BackgroundSpot({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.01,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 400, color: color.withOpacity(0.7))],
      ),
    );
  }
}

class PaymentPage extends GetView<PaymentPageController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox.expand(
            child: Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("디미페이 앱의 결제 QR를 스캔해주세요",
                  style: DPTypography.title(color: DPColors.grayscale1000)),
              const SizedBox(height: 48),
              Text("상품 스캔 창에서 결제 QR를 바로 스캔하면\n빠르게 결제를 완료할 수 있습니다",
                  textAlign: TextAlign.center,
                  style: DPTypography.header2(color: DPColors.grayscale600)),
              const SizedBox(height: 67),
              const SizedBox(height: 132),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DPIcons(Symbols.arrow_back_ios_new,
                      size: 24, color: DPColors.grayscale600),
                  const SizedBox(width: 24),
                  Text("상품 스캔 화면으로 돌아가기", style: DPTypography.header2())
                ],
              )
            ],
          ),
        ),
        Obx(() => AnimatedRotation(
              turns: PaymentPageController.to.turns,
              duration: const Duration(milliseconds: 5000),
              curve: Curves.easeInQuad,
              child: Stack(children: [
                ...PaymentPageController.to.backgroundSpot.map((spot) {
                  return AnimatedPositioned(
                    left: spot.left.value,
                    top: spot.top.value,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    child: BackgroundSpot(
                        size: spot.size, color: Color(spot.color)),
                  );
                }).toList()
              ]),
            ))
      ],
    )));
  }
}
