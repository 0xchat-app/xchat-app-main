import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';

class BannerItem {
  BannerItem({
    required this.image,
    required this.title,
    required this.text,
  });
  final Widget image;
  final String title;
  final String text;
}

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.items,
    required this.height,
    this.interval,
    this.indicatorColor = Colors.white,
    this.indicatorActiveColor,
    this.padding = EdgeInsets.zero,
  });

  final List<BannerItem> items;
  final double height;
  final Duration? interval;
  final Color indicatorColor;
  final Color? indicatorActiveColor;
  final EdgeInsets padding;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.interval == null || widget.interval == Duration.zero) return; // 关闭自动轮播
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval!, (_) {
      if (!mounted) return;
      final next = (_current + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          SizedBox(
            height: widget.height - 30.py,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (idx) => setState(() => _current = idx),
              itemBuilder: (_, i) => _ParallaxPage(
                item: widget.items[i],
                index: i,
                controller: _pageController,
                padding: widget.padding,
                offsetScale: 2,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: widget.padding,
            child: _buildIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    final activeColor = ColorToken.onPrimaryContainer.of(context);
    final inactiveColor = ColorToken.secondaryContainer.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.items.length, (i) {
        final isActive = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

class _ParallaxPage extends StatelessWidget {
  const _ParallaxPage({
    required this.item,
    required this.index,
    required this.controller,
    required this.padding,
    this.offsetScale = 1.0,
  });

  final BannerItem item;
  final int index;
  final PageController controller;
  final EdgeInsets padding;
  final double offsetScale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double page = controller.hasClients && controller.page != null
            ? controller.page!
            : controller.initialPage.toDouble();
        double delta = index - page;
        double width = MediaQuery.of(context).size.width;

        return Padding(
          padding: padding,
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(delta * width * 0.1 * offsetScale, 0),
                child: item.image,
              ),
              Transform.translate(
                offset: Offset(delta * width * 0.4 * offsetScale, 0),
                child: CLText.headlineSmall(
                  item.title,
                  maxLines: 1,
                ),
              ),
              Transform.translate(
                offset: Offset(delta * width * 0.4 * offsetScale, 0),
                child: CLText.titleMedium(
                  item.text,
                  colorToken: ColorToken.onSurface,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}