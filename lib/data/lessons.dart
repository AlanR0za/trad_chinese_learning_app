class Word {
  final String chinese;
  final String pinyin;
  final String english;
  final String type;

  Word({required this.chinese, required this.pinyin, required this.english, this.type = ''});
}

class Dialogue {
  final String dialogueName;
  final List<Word> words;

  Dialogue({required this.dialogueName, required this.words});
}

class Lesson {
  final int lessonNumber;
  final String lessonName;
  final List<Dialogue> dialogues;

  Lesson({required this.lessonNumber, required this.lessonName, required this.dialogues});
}

final lessons = <Lesson>[
  Lesson(
    lessonNumber: 7,
    lessonName: 'Lección 7',
    dialogues: [
      Dialogue(
        dialogueName: 'Diálogo 1',
        words: [
          Word(chinese: '點', pinyin: 'diǎn', english: "o'clock", type: '(M)'),
          Word(chinese: '唱歌', pinyin: 'chànggē', english: 'to sing', type: '(V-sep)'),
          Word(chinese: '分', pinyin: 'fēn', english: 'minute', type: '(M)'),
          Word(chinese: '見面', pinyin: 'jiànmiàn', english: 'meet', type: '(V-sep)'),
          Word(chinese: '從', pinyin: 'cóng', english: 'from', type: '(Prep)'),
          Word(chinese: '中午', pinyin: 'zhōngwǔ', english: 'noon', type: '(N)'),
          Word(chinese: '得', pinyin: 'děi', english: 'to have to, must', type: '(Vaux)'),
          Word(chinese: '銀行', pinyin: 'yínháng', english: 'bank', type: '(N)'),
          Word(chinese: '時候', pinyin: 'shíhòu', english: 'when', type: '(N)'),
          Word(chinese: '後天', pinyin: 'hòutiān', english: 'the day after tomorrow', type: '(N)'),
          Word(chinese: '大安', pinyin: "Dà'ān", english: 'Da-an (KTV name)', type: '(Names)'),
          Word(chinese: '下次', pinyin: 'xià cì', english: 'next time'),
          Word(chinese: '沒問題', pinyin: 'méi wèntí', english: 'No problem'),
          Word(chinese: '對了', pinyin: 'duìle', english: 'by the way'),
          Word(chinese: '有空', pinyin: 'yǒu kòng', english: 'to have free time'),
          Word(chinese: '再見', pinyin: 'zàijiàn', english: 'Goodbye'),
        ],
      ),
      Dialogue(
        dialogueName: 'Diálogo 2',
        words: [
          Word(chinese: '在', pinyin: 'zài', english: 'in the process of doing something', type: '(Vs)'),
          Word(chinese: '午餐', pinyin: 'wǔcān', english: 'lunch', type: '(N)'),
          Word(chinese: '剛', pinyin: 'gāng', english: 'just now', type: '(Adv)'),
          Word(chinese: '下課', pinyin: 'xiàkè', english: 'to finish class', type: '(V-sep)'),
          Word(chinese: '下午', pinyin: 'xiàwǔ', english: 'afternoon', type: '(N)'),
          Word(chinese: '半', pinyin: 'bàn', english: 'half', type: '(N)'),
          Word(chinese: '比賽', pinyin: 'bǐsài', english: 'game, competition', type: '(N)'),
          Word(chinese: '結束', pinyin: 'jiéshù', english: 'to finish', type: '(Vp)'),
          Word(chinese: '最近', pinyin: 'zuìjìn', english: 'recently, lately', type: '(N)'),
          Word(chinese: '忙', pinyin: 'máng', english: 'busy', type: '(Vs)'),
          Word(chinese: '每', pinyin: 'měi', english: 'every, each', type: '(Det)'),
          Word(chinese: '天', pinyin: 'tiān', english: 'day (measure word)', type: '(M)'),
          Word(chinese: '書法', pinyin: 'shūfǎ', english: 'calligraphy', type: '(N)'),
          Word(chinese: '課', pinyin: 'kè', english: 'class', type: '(N)'),
          Word(chinese: '開始', pinyin: 'kāishǐ', english: 'to begin, to start', type: '(Vp)'),
          Word(chinese: '字', pinyin: 'zì', english: 'character', type: '(N)'),
          Word(chinese: '寫', pinyin: 'xiě', english: 'to write', type: '(V)'),
          Word(chinese: '可以', pinyin: 'kěyǐ', english: 'may (permission)', type: '(Vaux)'),
          Word(chinese: '問', pinyin: 'wèn', english: 'to ask', type: '(V)'),
          Word(chinese: '等一下', pinyin: 'děng yíxià', english: 'later'),
          Word(chinese: '有事', pinyin: 'yǒu shì', english: 'to be busy, to be engaged'),
          Word(chinese: '有意思', pinyin: 'yǒu yìsi', english: 'to be interesting, to be fun'),
        ],
      ),
    ],
  ),
  Lesson(
    lessonNumber: 8,
    lessonName: 'Lección 8',
    dialogues: [
      Dialogue(
        dialogueName: 'Diálogo 1',
        words: [
          Word(chinese: '坐', pinyin: 'zuò', english: 'to take by, to travel by', type: '(V)'),
          Word(chinese: '火車', pinyin: 'huǒchē', english: 'train', type: '(N)'),
          Word(chinese: '跟', pinyin: 'gēn', english: 'with', type: '(Prep)'),
          Word(chinese: '玩', pinyin: 'wán', english: 'to have fun', type: '(V)'),
          Word(chinese: '怎麼', pinyin: 'zěnme', english: 'how', type: '(Adv)'),
          Word(chinese: '慢', pinyin: 'màn', english: 'slow', type: '(Vs)'),
          Word(chinese: '鐘頭', pinyin: 'zhōngtóu', english: 'hour', type: '(N)'),
          Word(chinese: '比較', pinyin: 'bǐjiào', english: '(comparatively) more', type: '(Adv)'),
          Word(chinese: '快', pinyin: 'kuài', english: 'fast', type: '(Vs)'),
          Word(chinese: '車票', pinyin: 'chēpiào', english: '(train, bus) ticket', type: '(N)'),
          Word(chinese: '非常', pinyin: 'fēicháng', english: 'very', type: '(Adv)'),
          Word(chinese: '但是', pinyin: 'dànshì', english: 'but, however', type: '(Conj)'),
          Word(chinese: '又', pinyin: 'yòu', english: 'both...and...', type: '(Adv)'),
          Word(chinese: '舒服', pinyin: 'shūfú', english: 'comfortable', type: '(Vs)'),
          Word(chinese: '站', pinyin: 'zhàn', english: 'station', type: '(N)'),
          Word(chinese: '或是', pinyin: 'huòshì', english: 'or', type: '(Conj)'),
          Word(chinese: '臺南', pinyin: 'Táinán', english: 'Tainan (city)', type: '(Names)'),
          Word(chinese: '高鐵', pinyin: 'gāotiě', english: 'High Speed Rail (HSR)', type: '(Names)'),
          Word(chinese: '網路上', pinyin: 'wǎnglu shàng', english: 'on the Internet'),
          Word(chinese: '便利商店', pinyin: 'biànlì shāngdiàn', english: 'convenience store'),
        ],
      ),
      Dialogue(
        dialogueName: 'Diálogo 2',
        words: [
          Word(chinese: '同學', pinyin: 'tóngxué', english: 'classmate', type: '(N)'),
          Word(chinese: '參觀', pinyin: 'cānguān', english: 'to visit (an institution)', type: '(V)'),
          Word(chinese: '古代', pinyin: 'gǔdài', english: 'ancient times', type: '(N)'),
          Word(chinese: '騎', pinyin: 'qí', english: 'to ride', type: '(V)'),
          Word(chinese: '機車', pinyin: 'jīchē', english: 'motorcycle, scooter', type: '(N)'),
          Word(chinese: '載', pinyin: 'zài', english: 'to give someone a ride', type: '(V)'),
          Word(chinese: '捷運', pinyin: 'jiéyùn', english: 'Mass Rapid Transit (MRT)', type: '(N)'),
          Word(chinese: '比', pinyin: 'bǐ', english: '(more...) than', type: '(Prep)'),
          Word(chinese: '故宮博物院', pinyin: 'Gùgōng Bówùyuàn', english: 'National Palace Museum', type: '(Names)'),
          Word(chinese: '中國', pinyin: 'Zhōngguó', english: 'China', type: '(Names)'),
          Word(chinese: '公共汽車', pinyin: 'gōnggòng qìchē', english: 'bus'),
          Word(chinese: '不行', pinyin: 'bù xíng', english: 'will not do'),
          Word(chinese: '計程車', pinyin: 'jìchéngchē', english: 'taxi'),
          Word(chinese: '差不多', pinyin: 'chàbùduō', english: 'about the same'),
        ],
      ),
    ],
  ),
];
