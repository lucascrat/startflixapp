import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';

class MovieCard extends StatefulWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double? width;

  const MovieCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // Responsive width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final cardWidth = widget.width ?? (isSmallScreen ? 100.0 : 120.0);
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    final iconSize = isSmallScreen ? 32.0 : 40.0;
    final margin = isSmallScreen ? 4.0 : 8.0;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: margin,
            vertical: _isFocused ? 2 : 4,
          ),
          width: cardWidth,
          transform: _isFocused
              ? Matrix4.identity().scaled(1.05)
              : Matrix4.identity(),
          decoration: _isFocused
              ? BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      (widget.item.logoUrl != null &&
                          widget.item.logoUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: widget.item.logoUrl!,
                          // Many IPTV streams use servers that protect images from bots.
                          // Setting a User-Agent often fixes proper loading.
                          memCacheWidth: 200,
                          memCacheHeight: 300,
                          httpHeaders: const {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                          },
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/app_icon.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Image.asset(
                          'assets/app_icon.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.title,
                style: TextStyle(
                  color: _isFocused ? Colors.yellow : Colors.white,
                  fontSize: fontSize,
                  fontWeight: curFontWeight(),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  FontWeight curFontWeight() => _isFocused ? FontWeight.bold : FontWeight.w500;
}
