import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_profile_page/models/repos_model.dart';
import 'package:github_profile_page/models/user_model.dart';
import 'package:github_profile_page/services/http_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user = User(siteAdmin: false, id: 1);
  bool isLoading = false;
  List<Repos> repo = [];

  void _apiLoadUser() async {
    setState(() {
      isLoading = true;
    });
    var users = await Network.GET(Network.API_USER, {});
    var repos = await Network.GET(Network.API_REPOS, {});
    if (users != null && repos != null) {
      setState(() {
        print(users);
        print(repos);
        user = Network.parseUser(users);
        repo = Network.parseRepos(repos);
        repo.sort((a, b) => b.stargazersCount!.compareTo(a.stargazersCount!));
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.share_outlined,
                color: Colors.blue.shade700,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.blue.shade700,
              )),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [
                        //User_info
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Image.network(
                                    user.avatarUrl!,
                                    height: 65,
                                    width: 65,
                                    fit: BoxFit.cover,
                                  )),
                              const SizedBox(width: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name!,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    user.login!,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        //follow
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.person),
                              Text(
                                " " + user.followers.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const Text(" followers",
                                  style: TextStyle(fontSize: 18)),
                              Text(
                                " · " + user.following.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const Text(" following",
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    height: 10,
                    thickness: 15,
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.star_border,
                      size: 35,
                    ),
                    horizontalTitleGap: 10,
                    title: Text(
                      "Popular",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return _popularRepos(repo[index]);
                        }),
                  ),
                  const Divider(),
                  _profileInfos(Icons.book_outlined, Colors.black.withOpacity(0.8), "Repositories", user.publicRepos!),
                  _profileInfos(Icons.home_work_outlined, Colors.orange, "Organizations", 0),
                  _profileInfos(Icons.star_border, Colors.yellow, "Starred", 0),
                ],
              ),
            ),
    );
  }

  Widget _popularRepos(Repos repo) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(left: 20, bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.5),
          border: Border.all(color: Colors.grey.shade300, width: 1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      repo.owner!.avatarUrl!,
                      height: 25,
                      width: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    repo.owner!.login!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ],
              ),
              Text(
                repo.name!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.yellow,
              ),
              Text(
                "  " + repo.stargazersCount.toString() + "  ",
                style: const TextStyle(fontSize: 18),
              ),
              const Icon(
                Icons.circle,
                color: Colors.greenAccent,
                size: 13,
              ),
              Text(
                "  " + repo.language!,
                style: const TextStyle(fontSize: 18),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _profileInfos(IconData iconData, Color color, String name, int number) {
    return SizedBox(
      height: 60,
      child: ListTile(
        leading: Container(
          alignment: Alignment.center,
          width: 40,
          height: 40,
          child: Icon(iconData, color: Colors.white,),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5)
          ),
        ),
        title: Text(name, style: TextStyle(fontSize: 20),),
        trailing: Text(number.toString(),style: TextStyle(fontSize: 20),),
      ),
    );
  }
}
