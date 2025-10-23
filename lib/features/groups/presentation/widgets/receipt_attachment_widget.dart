import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ReceiptAttachmentWidget extends StatefulWidget {
  final List<String> receiptUrls;
  final ValueChanged<List<String>> onReceiptsChanged;

  const ReceiptAttachmentWidget({
    Key? key,
    required this.receiptUrls,
    required this.onReceiptsChanged,
  }) : super(key: key);

  @override
  State<ReceiptAttachmentWidget> createState() =>
      _ReceiptAttachmentWidgetState();
}

class _ReceiptAttachmentWidgetState extends State<ReceiptAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  late List<String> _receiptUrls;

  @override
  void initState() {
    super.initState();
    _receiptUrls = List.from(widget.receiptUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_receiptUrls.isNotEmpty) ...[
          _buildReceiptGrid(),
          const SizedBox(height: 16),
        ],
        _buildAddReceiptButtons(),
      ],
    );
  }

  Widget _buildReceiptGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _receiptUrls.length,
        itemBuilder: (context, index) {
          return _buildReceiptThumbnail(_receiptUrls[index], index);
        },
      ),
    );
  }

  Widget _buildReceiptThumbnail(String url, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: url.startsWith('http')
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildReceiptPlaceholder();
                      },
                    )
                  : File(url).existsSync()
                      ? Image.file(
                          File(url),
                          fit: BoxFit.cover,
                        )
                      : _buildReceiptPlaceholder(),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeReceipt(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPlaceholder() {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt,
            size: 32,
            color: Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            'Receipt',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReceiptButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('From Gallery'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _receiptUrls.add(image.path);
        });
        widget.onReceiptsChanged(_receiptUrls);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeReceipt(int index) {
    setState(() {
      _receiptUrls.removeAt(index);
    });
    widget.onReceiptsChanged(_receiptUrls);
  }

  void _shareReceipt(BuildContext context) async {
    // Share receipt images
    if (_receiptUrls.isNotEmpty) {
      final files = _receiptUrls.map((url) => XFile(url)).toList();
      await Share.shareXFiles(files);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No receipt images to share'),
        ),
      );
    }
  }
}

/// Receipt viewer for full-screen display
class ReceiptViewerPage extends StatelessWidget {
  final List<String> receiptUrls;
  final int initialIndex;

  const ReceiptViewerPage({
    Key? key,
    required this.receiptUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Receipt ${initialIndex + 1} of ${receiptUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareReceipt(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: receiptUrls.length,
        itemBuilder: (context, index) {
          final url = receiptUrls[index];
          return InteractiveViewer(
            child: Center(
              child: url.startsWith('http')
                  ? Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.white,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : File(url).existsSync()
                      ? Image.file(
                          File(url),
                          fit: BoxFit.contain,
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt,
                                color: Colors.white,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Receipt not found',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
            ),
          );
        },
      ),
    );
  }

  void _shareReceipt(BuildContext context) async {
    // Share receipt images
    if (receiptUrls.isNotEmpty) {
      final files = receiptUrls.map((url) => XFile(url)).toList();
      await Share.shareXFiles(files);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No receipt images to share'),
        ),
      );
    }
  }
}
