import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';

class DownloadedCard extends StatefulWidget {

  final String title;
  final String situation;
  final VoidCallback onClick;
  final VoidCallback onMoreClick;
  final VoidCallback onDeleteClick;
  final VoidCallback onRedownloadClick;

  const DownloadedCard({
    super.key,
    required this.title,
    required this.situation,
    required this.onClick,
    required this.onMoreClick,
    required this.onDeleteClick,
    required this.onRedownloadClick
    });

  @override
  State<DownloadedCard> createState() => _DownloadedCardState();
}

class _DownloadedCardState extends State<DownloadedCard> {

  var formatClass = TimeSizeFormat();


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {
        widget.onClick();
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(  // ستون را پر می‌کند تا محتوای داخل آن به راست بچسبد
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.title,
                    textAlign: formatClass.textAlign(widget.title[0]),
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    maxLines: 2,
                  ),
                  Align(
                    alignment: Alignment.centerRight,  // آیکون‌ها را به راست تراز می‌کند
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.onMoreClick();
                          },
                          icon: const Icon(Icons.more_vert),
                        ),
                        
                        IconButton(
                          onPressed: () {
                            widget.onDeleteClick();
                          },
                          icon: const Icon(Icons.delete),
                        ),
                        if (widget.situation == 'failed')
                          IconButton(
                            onPressed: () {
                              widget.onRedownloadClick();
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                        if (widget.situation == 'completed')
                          const Icon(Icons.check)
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}