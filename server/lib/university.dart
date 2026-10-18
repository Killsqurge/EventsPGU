/// Справочник филиалов для веб-админки (должен совпадать с приложением).
abstract final class UniversityCatalog {
  static const branches = <Map<String, dynamic>>[
    {
      'id': 'ryb',
      'name': 'Рыбницкий',
      'departments': [
        {
          'id': 'ryb-econ',
          'name': 'Экономики и управления',
          'directions': [
            {'id': 'ryb-econ-fin', 'name': 'Финансы и кредит', 'courses': [1, 2, 3, 4]},
            {'id': 'ryb-econ-men', 'name': 'Менеджмент', 'courses': [1, 2, 3, 4]},
          ],
        },
        {
          'id': 'ryb-tech',
          'name': 'Технических наук',
          'directions': [
            {'id': 'ryb-tech-cs', 'name': 'Информатика и ВТ', 'courses': [1, 2, 3, 4, 5]},
            {'id': 'ryb-tech-el', 'name': 'Электроэнергетика', 'courses': [1, 2, 3, 4]},
          ],
        },
      ],
    },
    {
      'id': 'tir',
      'name': 'Тираспольский',
      'departments': [
        {
          'id': 'tir-math',
          'name': 'Математики и физики',
          'directions': [
            {'id': 'tir-math-app', 'name': 'Прикладная математика', 'courses': [1, 2, 3, 4]},
            {'id': 'tir-math-phys', 'name': 'Физика', 'courses': [1, 2, 3, 4]},
          ],
        },
        {
          'id': 'tir-hum',
          'name': 'Гуманитарных наук',
          'directions': [
            {'id': 'tir-hum-hist', 'name': 'История', 'courses': [1, 2, 3, 4]},
            {'id': 'tir-hum-law', 'name': 'Юриспруденция', 'courses': [1, 2, 3, 4, 5]},
          ],
        },
      ],
    },
  ];
}
