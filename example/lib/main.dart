import 'package:flutter/material.dart';
import 'package:better_versions/better_versions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize version manager
  final versionManager = VersionManager(
    projectRoot: '.',
    versionFormat: VersionFormat.timestamp,
  );
  
  // Get current version
  final currentVersion = await versionManager.getCurrentVersion();
  
  runApp(MyApp(versionInfo: currentVersion));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> versionInfo;
  
  const MyApp({super.key, required this.versionInfo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Versions Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VersionManagerDemo(),
    );
  }
}

class VersionManagerDemo extends StatefulWidget {
  const VersionManagerDemo({super.key});

  @override
  State<VersionManagerDemo> createState() => _VersionManagerDemoState();
}

class _VersionManagerDemoState extends State<VersionManagerDemo> {
  final _versionManager = VersionManager(projectRoot: '.');
  Map<String, dynamic> _versionInfo = {};
  bool _isLoading = true;
  String _lastAction = '';
  
  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }
  
  Future<void> _loadVersionInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await _versionManager.getCurrentVersion();
      setState(() {
        _versionInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _versionInfo = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateVersion(Future<void> Function() action, String actionName) async {
    try {
      await action();
      await _loadVersionInfo();
      setState(() {
        _lastAction = 'Success: $actionName';
      });
    } catch (e) {
      setState(() {
        _lastAction = 'Error during $actionName: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Better Versions Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVersionCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
          if (_lastAction.isNotEmpty) _buildLastAction(),
        ],
      ),
    );
  }
  
  Widget _buildVersionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Version',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Version: ${_versionInfo['major'] ?? 'N/A'}.${_versionInfo['minor'] ?? 'N/A'}.${_versionInfo['patch'] ?? 'N/A'}'),
            if (_versionInfo['preRelease'] != null)
              Text('Pre-release: ${_versionInfo['preRelease']}'),
            if (_versionInfo['buildMetadata'] != null)
              Text('Build: ${_versionInfo['buildMetadata']}'),
            if (_versionInfo['error'] != null)
              Text('Error: ${_versionInfo['error']}', 
                   style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Version Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => _updateVersion(
                () => _versionManager.bumpMajor(),
                'Bump Major Version',
              ),
              child: const Text('Bump Major'),
            ),
            ElevatedButton(
              onPressed: () => _updateVersion(
                () => _versionManager.bumpMinor(),
                'Bump Minor Version',
              ),
              child: const Text('Bump Minor'),
            ),
            ElevatedButton(
              onPressed: () => _updateVersion(
                () => _versionManager.bumpPatch(),
                'Bump Patch Version',
              ),
              child: const Text('Bump Patch'),
            ),
            ElevatedButton(
              onPressed: () => _updateVersion(
                () => _versionManager.setPreRelease('beta.1'),
                'Set Pre-release',
              ),
              child: const Text('Set Beta'),
            ),
            ElevatedButton(
              onPressed: () => _updateVersion(
                () => _versionManager.removePreRelease(),
                'Remove Pre-release',
              ),
              child: const Text('Remove Pre-release'),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLastAction() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _lastAction.startsWith('Error') ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(_lastAction),
    );
  }
}
