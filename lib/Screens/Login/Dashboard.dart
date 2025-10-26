// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, unnecessary_new, file_names, use_key_in_widget_constructors, prefer_collection_literals, avoid_unnecessary_containers, deprecated_member_use

// import 'package:ecm_application/Model/Project/Login/ProjectOverviewModel.dart';
import 'package:ecm_application/Model/Project/Login/State_list_Model.dart';
import 'package:ecm_application/Operations/StatelistOperation.dart';
import 'package:ecm_application/Provider/InternetProvider.dart';
import 'package:ecm_application/Screens/Login/ProjectMenuScreen.dart';
import 'package:ecm_application/Screens/Login/MyDrawerScreen.dart';
import 'package:ecm_application/Widget/NoInternet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsCategoryScreen extends StatefulWidget {
  @override
  State<ProjectsCategoryScreen> createState() => _ProjectsCategoryScreenState();
}

class _ProjectsCategoryScreenState extends State<ProjectsCategoryScreen> {
  // late InternetProvider dpr;
  @override
  void initState() {
    super.initState();

    searchController = TextEditingController();
    getProjectList();
  }

  Set<String>? stateList;
  String? selectState;
  List<ProjectModel>? projectList;
  ProjectModel? selectProject;
  Future<List<ProjectModel>>? futureProjectList;
  late TextEditingController searchController;
  String query = '';

  getProjectList() {
    setState(() {
      stateList = Set();
      stateList!.add('ALL STATE');
      projectList = [];
      projectList!.add(new ProjectModel(id: 0, projectName: 'ALL PROJECT'));
      selectState = stateList!.first;
      selectProject = projectList!.first;
      futureProjectList = getStateAuthority();
      futureProjectList!.then((value) {
        projectList!.addAll(value);
        for (var element in value) {
          stateList!.add(element.state!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ip = Provider.of<InternetProvider>(context);

    Widget? child;

    switch (ip.connectionStatus) {
      case 'checking':
        child = const Center(child: CircularProgressIndicator());
        break;
      case 'connected':
        child = RefreshIndicator(
          onRefresh: () async {
            await getProjectList();
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: searchController,
                      onChanged: (value) => {
                        setState(() {
                          query = value.toLowerCase();
                        })
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search by Project or State',
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        suffixIcon: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                        future: futureProjectList,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(211, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(25)),
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                          height: 100,
                                          width: 100,
                                          image: AssetImage(
                                              'assets/images/storm.png')),
                                      Text(
                                        'OPPS!',
                                        softWrap: true,
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 24,
                                            fontFamily: "RaleWay",
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10, right: 10),
                                        child: Text(
                                          'it seems Something went wrong with the Connection please try after sometime',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: "RaleWay",
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            await getProjectList();
                                          },
                                          child: Text('Refresh'))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            var data = query.isEmpty
                                ? snapshot.data
                                : (snapshot.data as List<ProjectModel>)
                                    .where((element) =>
                                        element.projectName!
                                            .toLowerCase()
                                            .contains(query) ||
                                        element.state!
                                            .toLowerCase()
                                            .contains(query))
                                    .toList();

                            return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 201, 222, 240),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(1, 1.5),
                                              blurRadius: 1.0,
                                              spreadRadius: 0.4)
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(3.5)),
                                    child: ListTile(
                                      splashColor: Colors.blue[100],
                                      onTap: () async {
                                        setVaribales(data[index]);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProjectMenuScreen(
                                                    data[index]
                                                        .projectName!
                                                        .toString(),
                                                  )),
                                          (Route<dynamic> route) => true,
                                        );
                                      },
                                      shape: BeveledRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3.5)),
                                      leading: SizedBox(
                                        height: 80,
                                        child: Image.asset(getStateImage(
                                            data[index].state!.toLowerCase())!),
                                      ),
                                      title: Text(
                                        data[index].projectName ?? '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (data[index].description != 'NA')
                                            Text(
                                              '${data[index].description}',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                          Text(
                                            "${data[index].state} (CCA:${data[index].totalArea ?? '0'})",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case 'disconnected':
        child = Center(
          child: NoInternetIllustration(
            title: "No Internet Connection",
            subtitle: "Reconnect to continue using the app.",
            onRetry: () {
              final internetProvider =
                  Provider.of<InternetProvider>(context, listen: false);
              internetProvider.connectionStream.listen((status) {
                if (status == 'connected') {
                  getProjectList();
                }
              });
            },
          ),
        );
        break;
      default:
    }
    return Scaffold(
        backgroundColor: Colors.white,
        drawer: MyDrawerScreen(),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'ECM Application'.toUpperCase(),
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        body: child);
  }

  void setVaribales(ProjectModel data) async {
    var hostip = data.hostIp;
    var dbName = data.project;
    var userName = data.userName;
    var pswd = data.password;
    String conString =
        'Data Source=$hostip;Initial Catalog=$dbName;User ID=$userName;Password=$pswd;';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString('EcString', data.eCString!);
      preferences.setString('DcString', data.dRString!);
      preferences.setString('RcString', data.rCString!);
      preferences.setString('HostIp', hostip!);
      preferences.setString('UserName', userName!);
      preferences.setString('Password', pswd!);
      preferences.setString('DatabaseName', dbName!);
      preferences.setString('ProjectName', data.projectName!);
      preferences.setString('ProjectId', data.id!.toString());
      preferences.setString(
          'AllowDeviceTypeString', data.allowDeviceTypeString!);
      preferences.setString('ConString', conString);

      preferences.setString('StateName', data.state!);
    });
  }

  getpop(context) {
    return showDialog(
      barrierDismissible: false,
      useSafeArea: false,
      context: context,
      builder: (ctx) => Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  String? getStateImage(String state) {
    String? imagePath;
    try {
      switch (state) {
        case 'madhya pradesh':
          imagePath = 'assets/images/MPlogo.png';
          break;
        case 'odisha':
          imagePath = 'assets/images/odishalogo.png';
          break;
        case 'maharashtra':
          imagePath = 'assets/images/maharastraLogo.png';
          break;
        default:
          imagePath = 'assets/images/Logo.png';
      }
    } catch (e) {
      imagePath = 'assets/images/Logo.png';
    }

    return imagePath;
  }
}
