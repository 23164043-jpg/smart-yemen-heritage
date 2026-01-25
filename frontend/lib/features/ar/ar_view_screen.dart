import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/config/landmark_models.dart';
import '../../core/config/antiquities_models.dart';

class ARViewScreen extends StatefulWidget {
  final String? modelUrl;
  final String title;
  final String? landmarkId;
  final bool isAntiquity; // لتحديد إذا كان الأثر من قسم الآثار

  const ARViewScreen({
    Key? key,
    this.modelUrl,
    required this.title,
    this.landmarkId,
    this.isAntiquity = false, // الافتراضي معلم
  }) : super(key: key);

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  bool _isAssetPath(String source) => source.startsWith('assets/');

  Future<void> _initWebView() async {
    // الحصول على رابط النموذج بناءً على النوع (معلم أو أثر)
    final modelSource = widget.isAntiquity 
        ? AntiquitiesModels.getModelUrl(widget.title)
        : LandmarkModels.getModelUrl(widget.title);

    print('🔍 البحث عن نموذج ${widget.isAntiquity ? "للأثر" : "للمعلم"}: ${widget.title}');
    print('📦 رابط النموذج: $modelSource');

    // التحقق إذا كان النموذج من Sketchfab
    final isSketchfab = modelSource.startsWith('sketchfab:');
    final String htmlContent;

    if (isSketchfab) {
      // استخراج معرف النموذج من Sketchfab
      final sketchfabId = modelSource.replaceFirst('sketchfab:', '');
      htmlContent = _getSketchfabHtml(sketchfabId);
    } else {
      if (_isAssetPath(modelSource)) {
        try {
          final byteData = await rootBundle.load(modelSource);
          final glbBytes = byteData.buffer.asUint8List();
          final glbBase64 = base64Encode(glbBytes);
          htmlContent = _getModelViewerHtml(modelSource, glbBase64: glbBase64);
        } catch (e) {
          print('❌ Failed to load asset model: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'تعذر تحميل النموذج المحلي: $modelSource';
            });
          }
          return;
        }
      } else {
        htmlContent = _getModelViewerHtml(modelSource);
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1a1a2e))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('🌐 Page started loading');
          },
          onPageFinished: (url) {
            print('✅ Page finished loading');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            print('❌ Web resource error: ${error.description}');
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  /// HTML لعرض نماذج Sketchfab
  String _getSketchfabHtml(String modelId) {
    return '''
<!DOCTYPE html>
<html lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>${widget.title}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    }
    iframe {
      width: 100%;
      height: 100%;
      border: none;
    }
    .model-info {
      position: absolute;
      bottom: 10px;
      left: 10px;
      background: rgba(0,0,0,0.7);
      color: #D4AF37;
      padding: 8px 12px;
      border-radius: 8px;
      font-size: 12px;
      z-index: 100;
    }
  </style>
</head>
<body>
  <iframe 
    title="${widget.title}"
    allowfullscreen 
    mozallowfullscreen="true" 
    webkitallowfullscreen="true" 
    allow="autoplay; fullscreen; xr-spatial-tracking" 
    src="https://sketchfab.com/models/$modelId/embed?autostart=1&ui_theme=dark">
  </iframe>
  <div class="model-info">📍 ${widget.title}</div>
</body>
</html>
''';
  }

  /// HTML لعرض نماذج model-viewer
  String _getModelViewerHtml(String modelSource, {String? glbBase64}) {
    final isLocalAsset = glbBase64 != null && glbBase64.isNotEmpty;
    return '''
<!DOCTYPE html>
<html lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>عرض ثلاثي الأبعاد - ${widget.title}</title>
  <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    }
    model-viewer {
      width: 100%;
      height: 100%;
      background-color: transparent;
      --poster-color: transparent;
    }
    model-viewer::part(default-progress-bar) {
      background-color: #D4AF37;
      height: 4px;
    }
    .loading-container {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
      color: white;
      font-family: 'Segoe UI', Tahoma, sans-serif;
    }
    .spinner {
      width: 50px;
      height: 50px;
      border: 4px solid rgba(212, 175, 55, 0.3);
      border-top-color: #D4AF37;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin: 0 auto 15px;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .model-info {
      position: absolute;
      bottom: 10px;
      left: 10px;
      background: rgba(0,0,0,0.7);
      color: #D4AF37;
      padding: 8px 12px;
      border-radius: 8px;
      font-size: 12px;
    }
  </style>
</head>
<body>
  <model-viewer
    id="viewer"
    src="${isLocalAsset ? '' : modelSource}"
    alt="${widget.title}"
    auto-rotate
    auto-rotate-delay="0"
    rotation-per-second="30deg"
    camera-controls
    touch-action="pan-y"
    interaction-prompt="auto"
    shadow-intensity="1"
    exposure="1"
    environment-image="neutral"
    loading="eager"
    reveal="auto"
  >
    <div class="loading-container" slot="poster">
      <div class="spinner"></div>
      <p>جاري تحميل النموذج...</p>
    </div>
  </model-viewer>
  
  <div class="model-info" id="modelInfo">🌐 نموذج تجريبي</div>

  <script>
    const viewer = document.getElementById('viewer');
    const modelInfo = document.getElementById('modelInfo');

    const isLocalAsset = ${isLocalAsset ? 'true' : 'false'};
    if (isLocalAsset) {
      modelInfo.innerHTML = '📦 نموذج محلي';
      const glbBase64 = '${glbBase64 ?? ''}';

      // استخدم fetch على data URL لتجنب حلقات JS الثقيلة
      const dataUrl = 'data:model/gltf-binary;base64,' + glbBase64;
      fetch(dataUrl)
        .then((r) => r.blob())
        .then((blob) => {
          const url = URL.createObjectURL(blob);
          viewer.src = url;
        })
        .catch((e) => {
          console.error('Failed to create blob url:', e);
          modelInfo.innerHTML = '❌ خطأ في تحميل النموذج المحلي';
          modelInfo.style.color = '#ff6b6b';
        });
    }
    
    viewer.addEventListener('load', () => {
      console.log('Model loaded successfully');
      modelInfo.innerHTML = '✅ تم التحميل';
    });
    
    viewer.addEventListener('error', (e) => {
      console.error('Model loading error:', e);
      modelInfo.innerHTML = '❌ خطأ في التحميل';
      modelInfo.style.color = '#ff6b6b';
    });
    
    viewer.addEventListener('progress', (e) => {
      const progress = Math.round(e.detail.totalProgress * 100);
      modelInfo.innerHTML = '⏳ ' + progress + '%';
    });
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomModel = widget.isAntiquity 
        ? AntiquitiesModels.hasModel(widget.title)
        : LandmarkModels.hasCustomModel(widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              hasCustomModel ? 'نموذج مخصص' : 'نموذج تجريبي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color:
                    hasCustomModel ? const Color(0xFFD4AF37) : Colors.white60,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _initWebView();
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView لعرض النموذج
          WebViewWidget(controller: _controller),

          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: const Color(0xFF1a1a2e),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFD4AF37),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'جاري تحميل النموذج ثلاثي الأبعاد...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'يرجى الانتظار',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // رسالة الخطأ
          if (_hasError)
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'خطأ في تحميل النموذج',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // تعليمات الاستخدام
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ControlHint(icon: Icons.touch_app, label: 'اسحب للتدوير'),
                  _ControlHint(icon: Icons.pinch, label: 'قرّب للتكبير'),
                  _ControlHint(icon: Icons.open_with, label: 'اسحب بإصبعين'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final hasCustomModel = widget.isAntiquity 
        ? AntiquitiesModels.hasModel(widget.title)
        : LandmarkModels.hasCustomModel(widget.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'كيفية الاستخدام',
          style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HelpItem(
                icon: Icons.touch_app, text: 'اسحب بإصبعك لتدوير النموذج'),
            const _HelpItem(
                icon: Icons.pinch, text: 'استخدم إصبعين للتكبير والتصغير'),
            const _HelpItem(
                icon: Icons.pan_tool, text: 'اسحب بإصبعين لتحريك النموذج'),
            const Divider(color: Colors.white24, height: 24),
            _HelpItem(
              icon: hasCustomModel ? Icons.check_circle : Icons.info_outline,
              text: hasCustomModel
                  ? 'هذا نموذج مخصص لمعلم ${widget.title}'
                  : 'هذا نموذج تجريبي. سيتم إضافة نموذج مخصص قريباً.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'فهمت',
              style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ControlHint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 10, fontFamily: 'Cairo'),
        ),
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
