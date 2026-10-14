class Direction {
  const Direction({required this.id, required this.name, required this.courses});

  final String id;
  final String name;
  final List<int> courses;
}

class Department {
  const Department({required this.id, required this.name, required this.directions});

  final String id;
  final String name;
  final List<Direction> directions;
}

class Branch {
  const Branch({required this.id, required this.name, required this.departments});

  final String id;
  final String name;
  final List<Department> departments;
}

abstract final class UniversityData {
  static const branches = <Branch>[
    Branch(
      id: 'ryb',
      name: 'Рыбницкий',
      departments: [
        Department(
          id: 'ryb-econ',
          name: 'Экономики и управления',
          directions: [
            Direction(id: 'ryb-econ-fin', name: 'Финансы и кредит', courses: [1, 2, 3, 4]),
            Direction(id: 'ryb-econ-men', name: 'Менеджмент', courses: [1, 2, 3, 4]),
          ],
        ),
        Department(
          id: 'ryb-tech',
          name: 'Технических наук',
          directions: [
            Direction(id: 'ryb-tech-cs', name: 'Информатика и ВТ', courses: [1, 2, 3, 4, 5]),
            Direction(id: 'ryb-tech-el', name: 'Электроэнергетика', courses: [1, 2, 3, 4]),
          ],
        ),
      ],
    ),
    Branch(
      id: 'tir',
      name: 'Тираспольский',
      departments: [
        Department(
          id: 'tir-math',
          name: 'Математики и физики',
          directions: [
            Direction(id: 'tir-math-app', name: 'Прикладная математика', courses: [1, 2, 3, 4]),
            Direction(id: 'tir-math-phys', name: 'Физика', courses: [1, 2, 3, 4]),
          ],
        ),
        Department(
          id: 'tir-hum',
          name: 'Гуманитарных наук',
          directions: [
            Direction(id: 'tir-hum-hist', name: 'История', courses: [1, 2, 3, 4]),
            Direction(id: 'tir-hum-law', name: 'Юриспруденция', courses: [1, 2, 3, 4, 5]),
          ],
        ),
      ],
    ),
  ];

  static Branch? branch(String? id) {
    if (id == null) return null;
    for (final item in branches) {
      if (item.id == id) return item;
    }
    return null;
  }

  static Department? department(String? branchId, String? departmentId) {
    final current = branch(branchId);
    if (current == null || departmentId == null) return null;
    for (final item in current.departments) {
      if (item.id == departmentId) return item;
    }
    return null;
  }

  static Direction? direction(String? id) {
    if (id == null) return null;
    for (final current in branches) {
      for (final dept in current.departments) {
        for (final item in dept.directions) {
          if (item.id == id) return item;
        }
      }
    }
    return null;
  }

  static Department? departmentOfDirection(String directionId) {
    for (final current in branches) {
      for (final dept in current.departments) {
        for (final item in dept.directions) {
          if (item.id == directionId) return dept;
        }
      }
    }
    return null;
  }
}
