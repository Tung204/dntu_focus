import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  print('🔍 Analyzing Figma Design File...\n');
  
  // Read .env file
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  final envLines = envContent.split('\n');
  
  String? token;
  String? fileId;
  
  for (final line in envLines) {
    if (line.startsWith('FIGMA_ACCESS_TOKEN=')) {
      token = line.split('=')[1].trim();
    } else if (line.startsWith('FIGMA_FILE_ID=')) {
      fileId = line.split('=')[1].trim();
    }
  }
  
  if (token == null || fileId == null) {
    print('❌ Error: Credentials not found');
    return;
  }
  
  try {
    // Fetch file data
    print('📥 Fetching file data from Figma...');
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('https://api.figma.com/v1/files/$fileId'),
    );
    request.headers.set('X-Figma-Token', token);
    
    final response = await request.close();
    
    if (response.statusCode != 200) {
      print('❌ Error: HTTP ${response.statusCode}');
      return;
    }
    
    final responseBody = await response.transform(utf8.decoder).join();
    final data = json.decode(responseBody) as Map<String, dynamic>;
    
    print('✅ Data fetched successfully!\n');
    print('=' * 80);
    print('FILE INFORMATION');
    print('=' * 80);
    print('Name: ${data['name']}');
    print('Last Modified: ${data['lastModified']}');
    print('Version: ${data['version']}');
    print('Role: ${data['role']}');
    print('');
    
    // Analyze document structure
    final document = data['document'] as Map<String, dynamic>;
    final pages = document['children'] as List<dynamic>;
    
    print('=' * 80);
    print('PAGES STRUCTURE');
    print('=' * 80);
    print('Total pages: ${pages.length}\n');
    
    for (var i = 0; i < pages.length; i++) {
      final page = pages[i] as Map<String, dynamic>;
      print('Page ${i + 1}: ${page['name']}');
      print('  ID: ${page['id']}');
      print('  Type: ${page['type']}');
      
      if (page['children'] != null) {
        final frames = page['children'] as List<dynamic>;
        print('  Frames: ${frames.length}');
        
        // List first 10 frames
        final framesToShow = frames.take(10).toList();
        for (var j = 0; j < framesToShow.length; j++) {
          final frame = framesToShow[j] as Map<String, dynamic>;
          print('    ${j + 1}. ${frame['name']} (${frame['type']}) - ID: ${frame['id']}');
        }
        
        if (frames.length > 10) {
          print('    ... and ${frames.length - 10} more frames');
        }
      }
      print('');
    }
    
    // Analyze colors
    print('=' * 80);
    print('COLOR ANALYSIS');
    print('=' * 80);
    final colors = await _extractColors(document);
    print('Found ${colors.length} unique colors:\n');
    
    final colorList = colors.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (var i = 0; i < colorList.take(20).length; i++) {
      final entry = colorList[i];
      print('${i + 1}. ${entry.key} (used ${entry.value} times)');
    }
    
    if (colors.length > 20) {
      print('... and ${colors.length - 20} more colors');
    }
    print('');
    
    // Analyze text styles
    print('=' * 80);
    print('TEXT STYLES ANALYSIS');
    print('=' * 80);
    final textStyles = await _extractTextStyles(document);
    print('Found ${textStyles.length} unique text styles:\n');
    
    for (var i = 0; i < textStyles.take(15).length; i++) {
      final style = textStyles[i];
      print('${i + 1}. ${style['fontFamily']} ${style['fontWeight']} - ${style['fontSize']}px');
      print('   Line height: ${style['lineHeight']}, Letter spacing: ${style['letterSpacing']}');
    }
    
    if (textStyles.length > 15) {
      print('... and ${textStyles.length - 15} more text styles');
    }
    print('');
    
    // Analyze components
    print('=' * 80);
    print('COMPONENTS ANALYSIS');
    print('=' * 80);
    final components = await _extractComponents(document);
    print('Found ${components.length} components:\n');
    
    final componentTypes = <String, int>{};
    for (final comp in components) {
      final type = comp['type'] as String? ?? 'Unknown';
      componentTypes[type] = (componentTypes[type] ?? 0) + 1;
    }
    
    print('Components by type:');
    componentTypes.forEach((type, count) {
      print('  - $type: $count');
    });
    print('');
    
    // List some components
    print('Sample components:');
    for (var i = 0; i < components.take(15).length; i++) {
      final comp = components[i];
      print('${i + 1}. ${comp['name']} (${comp['type']}) - ID: ${comp['id']}');
    }
    
    if (components.length > 15) {
      print('... and ${components.length - 15} more components');
    }
    print('');
    
    // Summary
    print('=' * 80);
    print('SUMMARY');
    print('=' * 80);
    print('✅ Total pages: ${pages.length}');
    print('✅ Total components: ${components.length}');
    print('✅ Unique colors: ${colors.length}');
    print('✅ Text styles: ${textStyles.length}');
    print('');
    print('📊 File is ready for design token extraction!');
    
    client.close();
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<Map<String, int>> _extractColors(Map<String, dynamic> node) async {
  final colors = <String, int>{};
  
  void traverse(dynamic node) {
    if (node is! Map<String, dynamic>) return;
    
    // Check fills
    if (node['fills'] != null && node['fills'] is List) {
      for (final fill in node['fills'] as List) {
        if (fill is Map && fill['type'] == 'SOLID' && fill['color'] != null) {
          final color = fill['color'] as Map<String, dynamic>;
          final r = ((color['r'] ?? 0) * 255).round();
          final g = ((color['g'] ?? 0) * 255).round();
          final b = ((color['b'] ?? 0) * 255).round();
          final a = (color['a'] ?? 1.0);
          
          final colorStr = 'RGBA($r, $g, $b, ${a.toStringAsFixed(2)})';
          colors[colorStr] = (colors[colorStr] ?? 0) + 1;
        }
      }
    }
    
    // Check strokes
    if (node['strokes'] != null && node['strokes'] is List) {
      for (final stroke in node['strokes'] as List) {
        if (stroke is Map && stroke['type'] == 'SOLID' && stroke['color'] != null) {
          final color = stroke['color'] as Map<String, dynamic>;
          final r = ((color['r'] ?? 0) * 255).round();
          final g = ((color['g'] ?? 0) * 255).round();
          final b = ((color['b'] ?? 0) * 255).round();
          final a = (color['a'] ?? 1.0);
          
          final colorStr = 'RGBA($r, $g, $b, ${a.toStringAsFixed(2)})';
          colors[colorStr] = (colors[colorStr] ?? 0) + 1;
        }
      }
    }
    
    // Traverse children
    if (node['children'] != null && node['children'] is List) {
      for (final child in node['children'] as List) {
        traverse(child);
      }
    }
  }
  
  traverse(node);
  return colors;
}

Future<List<Map<String, dynamic>>> _extractTextStyles(Map<String, dynamic> node) async {
  final styles = <Map<String, dynamic>>[];
  final seen = <String>{};
  
  void traverse(dynamic node) {
    if (node is! Map<String, dynamic>) return;
    
    if (node['type'] == 'TEXT' && node['style'] != null) {
      final style = node['style'] as Map<String, dynamic>;
      final key = '${style['fontFamily']}_${style['fontWeight']}_${style['fontSize']}';
      
      if (!seen.contains(key)) {
        seen.add(key);
        styles.add({
          'fontFamily': style['fontFamily'] ?? 'Unknown',
          'fontWeight': style['fontWeight'] ?? 400,
          'fontSize': style['fontSize'] ?? 14,
          'lineHeight': style['lineHeightPx'] ?? style['fontSize'] ?? 14,
          'letterSpacing': style['letterSpacing'] ?? 0,
        });
      }
    }
    
    if (node['children'] != null && node['children'] is List) {
      for (final child in node['children'] as List) {
        traverse(child);
      }
    }
  }
  
  traverse(node);
  return styles;
}

Future<List<Map<String, dynamic>>> _extractComponents(Map<String, dynamic> node) async {
  final components = <Map<String, dynamic>>[];
  
  void traverse(dynamic node) {
    if (node is! Map<String, dynamic>) return;
    
    // Check if it's a component or component instance
    if (node['type'] == 'COMPONENT' || 
        node['type'] == 'COMPONENT_SET' ||
        node['type'] == 'INSTANCE') {
      components.add({
        'id': node['id'],
        'name': node['name'],
        'type': node['type'],
      });
    }
    
    if (node['children'] != null && node['children'] is List) {
      for (final child in node['children'] as List) {
        traverse(child);
      }
    }
  }
  
  traverse(node);
  return components;
}