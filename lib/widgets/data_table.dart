import 'package:flutter/material.dart';
import 'package:ofm_admin/pages/employees.dart';
import '../models/employee.dart';
import '../providers/db.dart';

class DataTableWithSelection extends StatefulWidget {
  final List<Employee> employees;

  const DataTableWithSelection({required this.employees});

  @override
  _DataTableWithSelectionState createState() => _DataTableWithSelectionState();
}

class _DataTableWithSelectionState extends State<DataTableWithSelection> {
  final Set<Employee> selectedEmployees = {};

  void _onSelectedRow(bool selected, Employee employee) {
    setState(() {
      if (selected) {
        selectedEmployees.add(employee);
      } else {
        selectedEmployees.remove(employee);
      }
    });
  }

  void _editSelectedEmployee(BuildContext context, Employee employee) {
    final TextEditingController nameController =
        TextEditingController(text: employee.name);
    final TextEditingController emailController =
        TextEditingController(text: employee.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Employee"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close without saving
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Create a new Employee object with the updated data
                final updatedEmployee = Employee(
                    name: nameController.text,
                    email: emailController.text,
                    active: employee.active,
                    shops: employee.shops,
                    id: employee.id);

                // Update the employee in the database
                dbService.editEmployee(updatedEmployee);

                // Implement the database update logic

                Navigator.pop(context); // Close the dialog after saving

                selectedEmployees.clear();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedEmployee() {
    if (selectedEmployees.isNotEmpty) {
      final employee = selectedEmployees.first;

      // Show a confirmation dialog before deleting
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Employee"),
            content: Text("Are you sure you want to delete ${employee.name}?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cancel deletion
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (employee is List<Employee>) {
                    // If 'employee' is a list, use deleteEmployees
                    dbService.deleteEmployees(employee as List<Employee>);
                  } else if (employee is Employee) {
                    // If 'employee' is a single Employee, use deleteEmployee
                    dbService.deleteEmployee(employee);
                  } else {
                    // If the type doesn't match, throw an error or handle accordingly
                    throw Exception("Invalid type for employee");
                  }

                  selectedEmployees.clear(); // Clear the selection
                  setState(() {}); // Update the state to reflect changes
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (selectedEmployees
            .isNotEmpty) // Display edit and delete buttons when there are selected employees
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: selectedEmployees.length == 1,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    if (selectedEmployees.isNotEmpty) {
                      final employee = selectedEmployees
                          .first; // Get the first selected employee
                      _editSelectedEmployee(context,
                          employee); // Call the function to show the edit dialog
                    }
                  },
                ),
              ),
              Visibility(
                visible: selectedEmployees.isNotEmpty,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteSelectedEmployee,
                ),
              ),
            ],
          ),
        Expanded(
          child: DataTable(
            columns: [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Email")),
              DataColumn(label: Text("Shops")),
              DataColumn(label: Text("Active")),
              //DataColumn(label: Text(" "))
            ],
            rows: widget.employees.map((employee) {
              return DataRow(
                selected: selectedEmployees.contains(employee),
                onSelectChanged: (selected) =>
                    _onSelectedRow(selected!, employee),
                cells: [
                  DataCell(Text(employee.name)),
                  DataCell(Text(employee.email)),
                  DataCell(
                    Column(
                      children: employee.shops
                          .map((shop) => Text(shop.shop ?? ''))
                          .toList(),
                    ),
                  ),
                  DataCell(Text(employee.active.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
