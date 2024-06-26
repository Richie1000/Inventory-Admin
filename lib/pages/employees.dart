// import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/employee.dart';
import '../providers/db.dart';
import '../widgets/bottom_sheet.dart';
import '../models/shop.dart';
import '../widgets/data_table.dart';

bool activeDropdownValue = false;
late List<Shop> selectedShops;
List<Shop> shops = [];

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late List<Employee> selectedEmployees;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    selectedEmployees = [];
    _getShops();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showSnackbar(BuildContext context, String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }

    print("Rebuilding!!!!");
    return Scaffold(
      appBar: AppBar(
        title: Text("Employees"),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            _addEmployee(context);
          }),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          OverflowBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              // Visibility(
              //   visible: shops.length > 0,
              //   child: ElevatedButton.icon(
              //     icon: Icon(
              //       Icons.add_circle,
              //       color: Theme.of(context).primaryColor,
              //     ),
              //     label: Text(
              //       'Add',
              //     ),
              //     onPressed: () {
              //       _addEmployee(context);
              //     },
              //     // : RoundedRectangleBorder(
              //     //   borderRadius: BorderRadius.circular(30.0),
              //     // ),
              //   ),
              // ),
              Visibility(
                visible: selectedEmployees.length == 1 && shops.length > 0,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Edit',
                  ),
                  onPressed: () {
                    _editEmployee(context, selectedEmployees[0]);
                  },
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30.0),
                  // ),
                ),
              ),
              Visibility(
                visible: selectedEmployees.length > 0,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Delete',
                  ),
                  onPressed: () {
                    dbService.deleteEmployees(selectedEmployees).then((_) {
                      setState(() {
                        selectedEmployees = [];
                      });
                    }).catchError((error) {
                      if (error.toString().contains("NOINTERNET")) {
                        showSnackbar(context,
                            "You dont seem to have Internet Connection");
                      } else {
                        print(error);
                        showSnackbar(context,
                            "Sorry Something occured, Please Try again");
                      }
                    });
                  },
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30.0),
                  // ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                StreamBuilder<List<Employee>>(
                  stream: getItemsStream("employees"),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Employee>> snapshot) {
                    // Log the current state
                    //print('Snapshot data: ${snapshot.data}');
                    //print(dbService.employees.stream);

                    // If there's an error, show the error message
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // If the stream is still waiting, show a loading animation
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List<Widget>.filled(
                            5,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.black12,
                                highlightColor: Colors.black26,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    // If the connection state is done and no data is received, inform the user
                    if (snapshot.connectionState == ConnectionState.done &&
                        !snapshot.hasData) {
                      return Text("No data received");
                    }

                    // If there's no data or data is null, indicate it's empty
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text("No employees found");
                    }

                    // Now that we have data, let's create the DataTable
                    final employees = snapshot.data!;

                    return DataTableWithSelection(
                      employees: employees,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getShops() async {
    List<Shop> res = await dbService.getShops();
    if (mounted) {
      setState(() {
        shops = res;
        selectedShops = [];
      });
    }
  }

  void _onSelectedRow(bool selected, employee) async {
    setState(() {
      if (selected) {
        selectedEmployees.add(employee);
      } else {
        selectedEmployees.remove(employee);
      }
    });
  }

  void _addEmployee(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ShopsAlertDialog();
      },
    ).then((res) {
      //print(res);
      if (res && res != null) {
        //print("executing");
        showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              height: MediaQuery.of(context).size.height / 1.7,
              color: Color(0xFF737373),
              child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  ),
                ),
                child: Wrap(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: TextField(
                        controller: _nameController,
                        //autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Employee Name",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Employee Email",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: EmployeeActiveStatus(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                        left: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          OverflowBar(
                            children: <Widget>[
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _nameController.clear();
                                  _emailController.clear();
                                  selectedShops.clear();
                                  activeDropdownValue = false;
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  if (_nameController.text.isNotEmpty &&
                                      _emailController.text.isNotEmpty) {
                                    dbService
                                        .addEmployee(
                                      Employee(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        shops: selectedShops,
                                        active: activeDropdownValue,
                                      ),
                                    )
                                        .then((_) {
                                      Navigator.pop(context);
                                      _nameController.clear();
                                      _emailController.clear();
                                      selectedShops.clear();
                                      activeDropdownValue = false;
                                    }).catchError((error) {
                                      if (error
                                          .toString()
                                          .contains("NOINTERNET")) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "You dont seem to have Internet Connection"),
                                          ),
                                        );
                                      } else {
                                        print(error);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "There seems to be a problem. Please try again later."),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    });
  }

  void _editEmployee(BuildContext context, Employee employee) {
    _nameController.text = employee.name;
    activeDropdownValue = employee.active;

    employee.shops.forEach((employeeshop) {
      Shop? foundEmployeeShop = shops.firstWhere(
        (shop) => shop.shopid == employeeshop.shopid,
        orElse: () => Shop(shop: '', shopid: ''), // Provide default Shop object
      );

      selectedShops.add(foundEmployeeShop);
    });

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ShopsAlertDialog();
      },
    ).then(
      (res) {
        if (res && res != null) {
          showModalBottomSheetApp(
            context: context,
            builder: (BuildContext bc) {
              return Container(
                color: Color(0xFF737373),
                child: Container(
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                    ),
                  ),
                  child: Wrap(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextField(
                          controller: _nameController,
                          //autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Employee Name",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                "Active",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            EditDropdownButton(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0,
                          left: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Icon(
                              Icons.add_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            OverflowBar(
                              children: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _nameController.clear();
                                    selectedShops.clear();
                                    activeDropdownValue = false;
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_nameController.text.isNotEmpty) {
                                      dbService
                                          .editEmployee(
                                        Employee(
                                            name: _nameController.text,
                                            email: employee.email,
                                            shops: selectedShops,
                                            active: activeDropdownValue,
                                            roles: employee.roles),
                                      )
                                          .then((_) {
                                        Navigator.pop(context);
                                        _nameController.clear();
                                        selectedEmployees.clear();

                                        //print( .length.toString());
                                        activeDropdownValue = false;

                                        setState(() {
                                          selectedEmployees = [];
                                        });
                                        print("selected Employees: " +
                                            selectedEmployees.length
                                                .toString());
                                      }).catchError(
                                        (error) {
                                          if (error
                                              .toString()
                                              .contains("NOINTERNET")) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "You dont seem to have internet Connextion"),
                                              ),
                                            );
                                          } else {
                                            print(error);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "There seems to be a problem. Please try again later."),
                                              ),
                                            );
                                          }
                                          //_onSelectedRow(false, employee);
                                        },
                                      );
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class EditDropdownButton extends StatefulWidget {
  @override
  _EditDropdownButtonState createState() => _EditDropdownButtonState();
}

class _EditDropdownButtonState extends State<EditDropdownButton> {
  bool? activeDropdownValue; // Update to nullable boolean

  @override
  Widget build(BuildContext context) {
    return DropdownButton<bool>(
      value: activeDropdownValue,
      onChanged: (bool? newValue) {
        // Update parameter type to bool?
        if (newValue != null) {
          // Check if newValue is not null
          setState(() {
            activeDropdownValue = newValue;
          });
        }
      },
      items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
        return DropdownMenuItem<bool>(
          value: value,
          child: Text(
            value.toString().toUpperCase(),
          ),
        );
      }).toList(),
    );
  }
}

class ShopsAlertDialog extends StatefulWidget {
  @override
  _ShopsAlertDialogState createState() => _ShopsAlertDialogState();
}

class _ShopsAlertDialogState extends State<ShopsAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select shops to allocate employee to'),
      content: Container(
        width: 300,
        child: ListView.builder(
          itemCount: shops.length,
          itemBuilder: (BuildContext context, int index) => CheckboxListTile(
            title: Text(shops[index].shop ?? 'Default Value'),
            value: selectedShops.contains(shops[index]),
            onChanged: (bool? selected) {
              // Update parameter type to bool?
              if (selected != null) {
                // Check if selected is not null
                setState(() {
                  if (selected) {
                    selectedShops.add(shops[index]);
                  } else {
                    selectedShops.remove(shops[index]);
                  }
                });
              }
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            selectedShops.clear();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Proceed'),
          onPressed: () {
            if (selectedShops.length > 0) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ],
    );
  }
}

class EmployeeActiveStatus extends StatefulWidget {
  @override
  _EmployeeActiveStatusState createState() => _EmployeeActiveStatusState();
}

class _EmployeeActiveStatusState extends State<EmployeeActiveStatus> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            "Active",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ),
        DropdownButton<bool>(
          value: activeDropdownValue,
          onChanged: (bool? newValue) {
            setState(() {
              activeDropdownValue = newValue!;
            });
          },
          items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
            return DropdownMenuItem<bool>(
              value: value,
              child: Text(
                value.toString().toUpperCase(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
