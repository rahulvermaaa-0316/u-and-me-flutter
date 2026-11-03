import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const brand = Color(0xFF6C4CF1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  Get.put(AppController(prefs));
  runApp(const UAndMeApp());
}

class AppController extends GetxController {
  AppController(this.prefs);
  final SharedPreferences prefs;

  final RxString username = ''.obs;
  final RxString bio = 'Sharing little moments ✨'.obs;
  final RxBool darkMode = false.obs;
  final RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;
  final RxSet<int> likedPosts = <int>{}.obs;

  bool get isLoggedIn => prefs.getBool('loggedIn') ?? false;

  @override
  void onInit() {
    super.onInit();
    username.value = prefs.getString('username') ?? '';
    bio.value = prefs.getString('bio') ?? 'Sharing little moments ✨';
    darkMode.value = prefs.getBool('darkMode') ?? false;
    final saved = prefs.getStringList('posts') ?? [];
    posts.assignAll(saved.map((line) {
      final parts = line.split('|||');
      return <String, dynamic>{
        'author': parts.isNotEmpty ? parts[0] : 'U & Me member',
        'text': parts.length > 1 ? parts[1] : '',
        'likes': parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
      };
    }));
    if (posts.isEmpty) {
      posts.addAll([
        {'author': 'Aarav', 'text': 'Small moments, big memories. 🌤️', 'likes': 18},
        {'author': 'Mia', 'text': 'A little reminder to be kind to yourself 💜', 'likes': 32},
        {'author': 'Kabir', 'text': 'Weekend mood: explore somewhere new.', 'likes': 11},
      ]);
    }
  }

  Future<void> login(String name) async {
    username.value = name.trim().isEmpty ? 'Guest' : name.trim();
    await prefs.setString('username', username.value);
    await prefs.setBool('loggedIn', true);
  }

  Future<void> logout() async {
    await prefs.setBool('loggedIn', false);
    Get.offAllNamed('/login');
  }

  Future<void> addPost(String text) async {
    if (text.trim().isEmpty) return;
    posts.insert(0, {'author': username.value, 'text': text.trim(), 'likes': 0});
    await _savePosts();
  }

  Future<void> toggleLike(int index) async {
    final post = Map<String, dynamic>.from(posts[index]);
    final key = index;
    if (likedPosts.contains(key)) {
      likedPosts.remove(key);
      post['likes'] = (post['likes'] as int) - 1;
    } else {
      likedPosts.add(key);
      post['likes'] = (post['likes'] as int) + 1;
    }
    posts[index] = post;
    await _savePosts();
  }

  Future<void> _savePosts() async {
    await prefs.setStringList('posts', posts.map((p) =>
      '${(p['author'] ?? '').toString().replaceAll('|||', ' ')}|||'
      '${(p['text'] ?? '').toString().replaceAll('|||', ' ')}|||${p['likes']}'
    ).toList());
  }

  Future<void> saveProfile(String newName, String newBio) async {
    username.value = newName.trim().isEmpty ? username.value : newName.trim();
    bio.value = newBio.trim();
    await prefs.setString('username', username.value);
    await prefs.setString('bio', bio.value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode.value = value;
    await prefs.setBool('darkMode', value);
  }
}

class UAndMeApp extends StatelessWidget {
  const UAndMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AppController>();
    return Obx(() => GetMaterialApp(
      title: 'U & Me',
      debugShowCheckedModeBanner: false,
      themeMode: c.darkMode.value ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brand),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF8F7FC)),
        cardTheme: CardThemeData(
          color: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true, brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.dark),
      ),
      initialRoute: c.isLoggedIn ? '/home' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const MainShell()),
        GetPage(name: '/explore', page: () => const ExploreScreen()),
        GetPage(name: '/messages', page: () => const MessagesScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
      ],
    ));
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 76, height: 76, decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [brand, Color(0xFFB28AFF)]),
            borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40)),
          const SizedBox(height: 28),
          const Text('U & Me', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Your little corner of the internet.', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16)),
          const SizedBox(height: 32),
          const Text('Come on in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter a display name to start exploring.'),
          const SizedBox(height: 18),
          TextField(controller: name, textInputAction: TextInputAction.done,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: 'Your name')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () async {
              await Get.find<AppController>().login(name.text);
              Get.offAllNamed('/home');
            },
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Continue')),
          ),
          const SizedBox(height: 12),
          Text('Demo app: sign-in is stored locally on this device.', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
        ],
      )),
    ))));
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  final pages = const [FeedScreen(), ExploreBody(), MessagesBody(), ProfileBody()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('U & Me', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        actions: [
          IconButton(tooltip: 'Messages', onPressed: () => setState(() => tab = 2), icon: const Icon(Icons.chat_bubble_outline)),
          IconButton(tooltip: 'Settings', onPressed: () => Get.toNamed('/settings'), icon: const Icon(Icons.tune_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      floatingActionButton: tab == 0 ? FloatingActionButton.extended(
        onPressed: () => showCreatePost(context), icon: const Icon(Icons.add), label: const Text('Create post')) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<AppController>();
    return Obx(() => ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6C4CF1), Color(0xFF9C7BFF)]),
          borderRadius: BorderRadius.circular(22)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Make room for good moments ✨', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 6), Text('Share a thought. Find your people.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Your circle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(height: 86, child: ListView(scrollDirection: Axis.horizontal, children: const [
          StoryAvatar(name: 'Your story', color: Color(0xFFBBA7FF), icon: Icons.add),
          StoryAvatar(name: 'Aarav', color: Color(0xFFFFC7A8)),
          StoryAvatar(name: 'Mia', color: Color(0xFFFFBBD5)),
          StoryAvatar(name: 'Kabir', color: Color(0xFFA9D9FF)),
          StoryAvatar(name: 'Zoya', color: Color(0xFFB7E8C6)),
        ])),
        const SizedBox(height: 8),
        ...List.generate(c.posts.length, (i) => PostCard(
          post: c.posts[i], liked: c.likedPosts.contains(i),
          onLike: () => c.toggleLike(i))),
      ],
    ));
  }
}

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({super.key, required this.name, required this.color, this.icon});
  final String name; final Color color; final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(width: 68, margin: const EdgeInsets.only(right: 12),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(
        shape: BoxShape.circle, gradient: LinearGradient(colors: [brand, Color(0xFFFF8EB7)])),
        child: CircleAvatar(radius: 25, backgroundColor: color,
          child: Icon(icon ?? Icons.person, color: Colors.white))),
      const SizedBox(height: 5),
      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
    ]));
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.liked, required this.onLike});
  final Map<String, dynamic> post; final bool liked; final VoidCallback onLike;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 12, bottom: 4),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(backgroundColor: const Color(0xFFE5DEFF), child: Text((post['author'] as String? ?? 'U').isNotEmpty ? (post['author'] as String)[0].toUpperCase() : 'U', style: const TextStyle(color: brand, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(post['author'] ?? 'U & Me member', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Just now · Community', style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
        ])),
        const Icon(Icons.more_horiz),
      ]),
      const SizedBox(height: 16),
      Text(post['text'] ?? '', style: const TextStyle(fontSize: 15, height: 1.4)),
      const SizedBox(height: 16),
      Container(height: 150, width: double.infinity, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEDE7FF), Color(0xFFFFE5F0)])),
        child: const Center(child: Icon(Icons.auto_awesome_rounded, size: 44, color: brand))),
      const SizedBox(height: 10),
      Row(children: [
        IconButton(onPressed: onLike, icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.pink : null)),
        Text('${post['likes'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 18),
        const Icon(Icons.mode_comment_outlined, size: 21),
        const SizedBox(width: 6), const Text('Comment'),
        const Spacer(), const Icon(Icons.share_outlined),
      ]),
    ])),
  );
}

Future<void> showCreatePost(BuildContext context) async {
  final text = TextEditingController();
  await showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Create a post', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        TextField(controller: text, maxLines: 4, maxLength: 240, decoration: const InputDecoration(hintText: 'What would you like to share?')),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () async { await Get.find<AppController>().addPost(text.text); if (ctx.mounted) Navigator.pop(ctx); },
          child: const Text('Share with your circle'))),
      ]),
    ));
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell();
}

class ExploreBody extends StatefulWidget {
  const ExploreBody({super.key});
  @override
  State<ExploreBody> createState() => _ExploreBodyState();
}
class _ExploreBodyState extends State<ExploreBody> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final c = Get.find<AppController>();
    return Obx(() {
      final filtered = c.posts.where((p) => ('${p['author']} ${p['text']}').toLowerCase().contains(query.toLowerCase())).toList();
      return ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Find your people', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6), const Text('Discover conversations and fresh perspectives.'),
        const SizedBox(height: 18),
        TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search people or posts')),
        const SizedBox(height: 16),
        ...filtered.map((p) => Card(child: ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFFE5DEFF), child: Icon(Icons.person, color: brand)),
          title: Text(p['author'] ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(p['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.arrow_forward_ios, size: 15),
        ))),
        if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No matches yet. Try another search.')),
      ]);
    });
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell();
}
class MessagesBody extends StatelessWidget {
  const MessagesBody({super.key});
  @override
  Widget build(BuildContext context) {
    final people = [
      ('Mia Chen', 'That sounds amazing! 💜', '2m', Color(0xFFFFBBD5)),
      ('Aarav Sharma', 'See you soon 👋', '18m', Color(0xFFFFC7A8)),
      ('Zoya Khan', 'Sent you a photo', '1h', Color(0xFFB7E8C6)),
      ('Kabir Mehta', 'Thanks for sharing!', '3h', Color(0xFFA9D9FF)),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Messages', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6), const Text('Keep the conversation going.'),
      const SizedBox(height: 16),
      ...people.map((p) => Card(child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(backgroundColor: p.$4, child: const Icon(Icons.person, color: Colors.white)),
        title: Text(p.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(p.$2), trailing: Text(p.$3, style: const TextStyle(fontSize: 11)),
        onTap: () => Get.to(() => ChatScreen(name: p.$1)),
      ))),
    ]);
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.name});
  final String name;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  final messages = <String>['Hey! Welcome to U & Me 👋'];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.name)),
    body: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: messages.map((m) =>
        Align(alignment: Alignment.centerRight, child: Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE9E2FF), borderRadius: BorderRadius.circular(16)),
          child: Text(m, style: const TextStyle(color: Color(0xFF30205E))),
        ))).toList())),
      SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Write a message...'))),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: () { if (input.text.trim().isNotEmpty) setState(() { messages.add(input.text.trim()); input.clear(); }); }, icon: const Icon(Icons.send)),
      ]))),
    ]),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const MainShell();
}
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<AppController>();
    return Obx(() => ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 10),
      Center(child: Column(children: [
        Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [brand, Color(0xFFFF8EB7)])),
          child: const CircleAvatar(radius: 46, backgroundColor: Color(0xFFE5DEFF), child: Icon(Icons.person, size: 48, color: brand))),
        const SizedBox(height: 12),
        Text(c.username.value.isEmpty ? 'U & Me member' : c.username.value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6), Text(c.bio.value),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _stat('${c.posts.where((p) => p['author'] == c.username.value).length}', 'Posts'),
          _stat('128', 'Followers'), _stat('96', 'Following'),
        ]),
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: () => showEditProfile(context), icon: const Icon(Icons.edit_outlined), label: const Text('Edit profile')),
        const SizedBox(height: 10),
        const Align(alignment: Alignment.centerLeft, child: Text('Your recent posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ])),
      ...c.posts.where((p) => p['author'] == c.username.value).map((p) => Card(child: ListTile(
        leading: const Icon(Icons.article_outlined, color: brand), title: Text(p['text'] ?? ''), subtitle: Text('${p['likes']} likes')))),
    ]));
  }
  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.grey)),
  ]);
}

Future<void> showEditProfile(BuildContext context) async {
  final c = Get.find<AppController>();
  final name = TextEditingController(text: c.username.value);
  final bio = TextEditingController(text: c.bio.value);
  await showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Edit profile'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name')),
      const SizedBox(height: 10),
      TextField(controller: bio, decoration: const InputDecoration(labelText: 'Bio')),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      FilledButton(onPressed: () async { await c.saveProfile(name.text, bio.text); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text('Save')),
    ],
  ));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Personalise your space', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('Your preferences are saved on this device.'),
        const SizedBox(height: 18),
        Card(child: SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined, color: brand),
          title: const Text('Dark mode'), subtitle: const Text('Change the app appearance'),
          value: c.darkMode.value, onChanged: c.setDarkMode)),
        Card(child: const ListTile(
          leading: Icon(Icons.lock_outline, color: brand), title: Text('Privacy'),
          subtitle: Text('Demo profile data is stored locally on this device.'))),
        Card(child: const ListTile(
          leading: Icon(Icons.info_outline, color: brand), title: Text('About U & Me'),
          subtitle: Text('A student Flutter project for social connection.'))),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(onPressed: c.logout, icon: const Icon(Icons.logout), label: const Text('Log out')),
      ])),
    );
  }
}
