import React, { useState, useEffect } from 'react';
import { Volume2, CheckCircle, XCircle, RotateCcw, BookOpen, Sparkles, ChevronDown, ChevronRight, Trophy, Medal } from 'lucide-react';

const ChineseLearningApp = () => {
  const lessons = [
    {
      lessonNumber: 7,
      lessonName: "Lección 7",
      dialogues: [
        {
          dialogueName: "Diálogo 1",
          words: [
            { chinese: "點", pinyin: "diǎn", english: "o'clock", type: "(M)" },
            { chinese: "KTV", pinyin: "KTV", english: "Karaoke", type: "(N)" },
            { chinese: "唱歌", pinyin: "chànggē", english: "to sing", type: "(V-sep)" },
            { chinese: "分", pinyin: "fēn", english: "minute", type: "(M)" },
            { chinese: "見面", pinyin: "jiànmiàn", english: "meet", type: "(V-sep)" },
            { chinese: "從", pinyin: "cóng", english: "from", type: "(Prep)" },
            { chinese: "中午", pinyin: "zhōngwǔ", english: "noon", type: "(N)" },
            { chinese: "得", pinyin: "děi", english: "to have to, must", type: "(Vaux)" },
            { chinese: "銀行", pinyin: "yínháng", english: "bank", type: "(N)" },
            { chinese: "時候", pinyin: "shíhòu", english: "when", type: "(N)" },
            { chinese: "後天", pinyin: "hòutiān", english: "the day after tomorrow", type: "(N)" },
            { chinese: "大安", pinyin: "Dà'ān", english: "Da-an (KTV name)", type: "(Names)" },
            { chinese: "下次", pinyin: "xià cì", english: "next time", type: "" },
            { chinese: "沒問題", pinyin: "méi wèntí", english: "No problem", type: "" },
            { chinese: "對了", pinyin: "duìle", english: "by the way", type: "" },
            { chinese: "有空", pinyin: "yǒu kòng", english: "to have free time", type: "" },
            { chinese: "再見", pinyin: "zàijiàn", english: "Goodbye", type: "" }
          ]
        },
        {
          dialogueName: "Diálogo 2",
          words: [
            { chinese: "在", pinyin: "zài", english: "in the process of doing something", type: "(Vs)" },
            { chinese: "午餐", pinyin: "wǔcān", english: "lunch", type: "(N)" },
            { chinese: "剛", pinyin: "gāng", english: "just now", type: "(Adv)" },
            { chinese: "下課", pinyin: "xiàkè", english: "to finish class", type: "(V-sep)" },
            { chinese: "下午", pinyin: "xiàwǔ", english: "afternoon", type: "(N)" },
            { chinese: "半", pinyin: "bàn", english: "half", type: "(N)" },
            { chinese: "比賽", pinyin: "bǐsài", english: "game, competition", type: "(N)" },
            { chinese: "結束", pinyin: "jiéshù", english: "to finish", type: "(Vp)" },
            { chinese: "最近", pinyin: "zuìjìn", english: "recently, lately", type: "(N)" },
            { chinese: "忙", pinyin: "máng", english: "busy", type: "(Vs)" },
            { chinese: "每", pinyin: "měi", english: "every, each", type: "(Det)" },
            { chinese: "天", pinyin: "tiān", english: "day (measure word)", type: "(M)" },
            { chinese: "書法", pinyin: "shūfǎ", english: "calligraphy", type: "(N)" },
            { chinese: "課", pinyin: "kè", english: "class", type: "(N)" },
            { chinese: "開始", pinyin: "kāishǐ", english: "to begin, to start", type: "(Vp)" },
            { chinese: "字", pinyin: "zì", english: "character", type: "(N)" },
            { chinese: "寫", pinyin: "xiě", english: "to write", type: "(V)" },
            { chinese: "可以", pinyin: "kěyǐ", english: "may (permission)", type: "(Vaux)" },
            { chinese: "問", pinyin: "wèn", english: "to ask", type: "(V)" },
            { chinese: "等一下", pinyin: "děng yíxià", english: "later", type: "" },
            { chinese: "有事", pinyin: "yǒu shì", english: "to be busy, to be engaged", type: "" },
            { chinese: "有意思", pinyin: "yǒu yìsi", english: "to be interesting, to be fun", type: "" }
          ]
        }
      ]
    },
    {
      lessonNumber: 8,
      lessonName: "Lección 8",
      dialogues: [
        {
          dialogueName: "Diálogo 1",
          words: [
            { chinese: "坐", pinyin: "zuò", english: "to take by, to travel by", type: "(V)" },
            { chinese: "火車", pinyin: "huǒchē", english: "train", type: "(N)" },
            { chinese: "跟", pinyin: "gēn", english: "with", type: "(Prep)" },
            { chinese: "玩", pinyin: "wán", english: "to have fun", type: "(V)" },
            { chinese: "怎麼", pinyin: "zěnme", english: "how", type: "(Adv)" },
            { chinese: "慢", pinyin: "màn", english: "slow", type: "(Vs)" },
            { chinese: "鐘頭", pinyin: "zhōngtóu", english: "hour", type: "(N)" },
            { chinese: "比較", pinyin: "bǐjiào", english: "(comparatively) more", type: "(Adv)" },
            { chinese: "快", pinyin: "kuài", english: "fast", type: "(Vs)" },
            { chinese: "車票", pinyin: "chēpiào", english: "(train, bus) ticket", type: "(N)" },
            { chinese: "非常", pinyin: "fēicháng", english: "very", type: "(Adv)" },
            { chinese: "但是", pinyin: "dànshì", english: "but, however", type: "(Conj)" },
            { chinese: "又", pinyin: "yòu", english: "both...and...", type: "(Adv)" },
            { chinese: "舒服", pinyin: "shūfú", english: "comfortable", type: "(Vs)" },
            { chinese: "站", pinyin: "zhàn", english: "station", type: "(N)" },
            { chinese: "或是", pinyin: "huòshì", english: "or", type: "(Conj)" },
            { chinese: "臺南", pinyin: "Táinán", english: "Tainan (city)", type: "(Names)" },
            { chinese: "高鐵", pinyin: "gāotiě", english: "High Speed Rail (HSR)", type: "(Names)" },
            { chinese: "網路上", pinyin: "wǎnglu shàng", english: "on the Internet", type: "" },
            { chinese: "便利商店", pinyin: "biànlì shāngdiàn", english: "convenience store", type: "" }
          ]
        },
        {
          dialogueName: "Diálogo 2",
          words: [
            { chinese: "同學", pinyin: "tóngxué", english: "classmate", type: "(N)" },
            { chinese: "參觀", pinyin: "cānguān", english: "to visit (an institution)", type: "(V)" },
            { chinese: "古代", pinyin: "gǔdài", english: "ancient times", type: "(N)" },
            { chinese: "騎", pinyin: "qí", english: "to ride", type: "(V)" },
            { chinese: "機車", pinyin: "jīchē", english: "motorcycle, scooter", type: "(N)" },
            { chinese: "載", pinyin: "zài", english: "to give someone a ride", type: "(V)" },
            { chinese: "捷運", pinyin: "jiéyùn", english: "Mass Rapid Transit (MRT)", type: "(N)" },
            { chinese: "比", pinyin: "bǐ", english: "(more...) than", type: "(Prep)" },
            { chinese: "故宮博物院", pinyin: "Gùgōng Bówùyuàn", english: "National Palace Museum", type: "(Names)" },
            { chinese: "中國", pinyin: "Zhōngguó", english: "China", type: "(Names)" },
            { chinese: "公共汽車", pinyin: "gōnggòng qìchē", english: "bus", type: "" },
            { chinese: "不行", pinyin: "bù xíng", english: "will not do", type: "" },
            { chinese: "計程車", pinyin: "jìchéngchē", english: "taxi", type: "" },
            { chinese: "差不多", pinyin: "chàbùduō", english: "about the same", type: "" }
          ]
        }
      ]
    }
  ];

  const [expandedLesson, setExpandedLesson] = useState(null);
  const [selectedDialogue, setSelectedDialogue] = useState(null);
  const [mode, setMode] = useState('home');
  const [currentQuiz, setCurrentQuiz] = useState(0);
  const [score, setScore] = useState(0);
  const [quizAnswers, setQuizAnswers] = useState([]);
  const [showResult, setShowResult] = useState(false);
  const [selectedAnswer, setSelectedAnswer] = useState(null);
  const [userName, setUserName] = useState('');
  const [showNameInput, setShowNameInput] = useState(false);
  const [rankings, setRankings] = useState([]);
  const [showRankings, setShowRankings] = useState(false);

  // Load rankings from storage
  useEffect(() => {
    loadRankings();
  }, []);

  const loadRankings = async () => {
    try {
      const result = await window.storage.list('ranking:');
      if (result && result.keys) {
        const rankingData = await Promise.all(
          result.keys.map(async (key) => {
            const data = await window.storage.get(key);
            return data ? JSON.parse(data.value) : null;
          })
        );
        setRankings(rankingData.filter(r => r !== null).sort((a, b) => b.totalScore - a.totalScore));
      }
    } catch (error) {
      console.log('No rankings yet');
      setRankings([]);
    }
  };

  const speak = (text) => {
    if ('speechSynthesis' in window) {
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'zh-TW';
      utterance.rate = 0.8;
      speechSynthesis.speak(utterance);
    }
  };

  const toggleLesson = (lessonIndex) => {
    setExpandedLesson(expandedLesson === lessonIndex ? null : lessonIndex);
  };

  const selectDialogue = (lessonIndex, dialogueIndex) => {
    setSelectedDialogue({ lessonIndex, dialogueIndex });
    setMode('learn');
  };

  const startQuiz = () => {
    if (!userName.trim()) {
      setShowNameInput(true);
      return;
    }
    setMode('quiz');
    setCurrentQuiz(0);
    setScore(0);
    setShowResult(false);
    setSelectedAnswer(null);
    generateQuizAnswers(0);
  };

  const generateQuizAnswers = (index) => {
    const currentWords = lessons[selectedDialogue.lessonIndex].dialogues[selectedDialogue.dialogueIndex].words;
    const correct = currentWords[index];
    const allWords = lessons.flatMap(l => l.dialogues.flatMap(d => d.words));
    const others = allWords.filter(w => w.chinese !== correct.chinese);
    const shuffled = [...others].sort(() => Math.random() - 0.5).slice(0, 3);
    const answers = [...shuffled, correct].sort(() => Math.random() - 0.5);
    setQuizAnswers(answers);
  };

  const handleAnswer = (answer) => {
    const currentWords = lessons[selectedDialogue.lessonIndex].dialogues[selectedDialogue.dialogueIndex].words;
    setSelectedAnswer(answer);
    setShowResult(true);
    if (answer.chinese === currentWords[currentQuiz].chinese) {
      setScore(score + 1);
    }
  };

  const nextQuestion = () => {
    const currentWords = lessons[selectedDialogue.lessonIndex].dialogues[selectedDialogue.dialogueIndex].words;
    if (currentQuiz < currentWords.length - 1) {
      setCurrentQuiz(currentQuiz + 1);
      setShowResult(false);
      setSelectedAnswer(null);
      generateQuizAnswers(currentQuiz + 1);
    } else {
      saveScore();
      setMode('results');
    }
  };

  const saveScore = async () => {
    if (!userName.trim()) return;
    
    const lessonName = lessons[selectedDialogue.lessonIndex].lessonName;
    const dialogueName = lessons[selectedDialogue.lessonIndex].dialogues[selectedDialogue.dialogueIndex].dialogueName;
    const quizKey = `${lessonName} - ${dialogueName}`;
    
    try {
      const userKey = `ranking:${userName.toLowerCase().replace(/\s+/g, '_')}`;
      let userData = null;
      
      try {
        const result = await window.storage.get(userKey);
        userData = result ? JSON.parse(result.value) : null;
      } catch (error) {
        userData = null;
      }

      if (userData) {
        // Update existing user
        if (!userData.quizzes[quizKey] || score > userData.quizzes[quizKey]) {
          userData.quizzes[quizKey] = score;
          userData.totalScore = Object.values(userData.quizzes).reduce((a, b) => a + b, 0);
          userData.quizzesCompleted = Object.keys(userData.quizzes).length;
        }
      } else {
        // Create new user
        userData = {
          name: userName,
          quizzes: { [quizKey]: score },
          totalScore: score,
          quizzesCompleted: 1
        };
      }

      await window.storage.set(userKey, JSON.stringify(userData));
      await loadRankings();
    } catch (error) {
      console.error('Error saving score:', error);
    }
  };

  const resetToHome = () => {
    setMode('home');
    setSelectedDialogue(null);
    setCurrentQuiz(0);
    setScore(0);
    setShowResult(false);
    setSelectedAnswer(null);
  };

  const resetQuiz = () => {
    setMode('learn');
    setCurrentQuiz(0);
    setScore(0);
    setShowResult(false);
    setSelectedAnswer(null);
  };

  const currentWords = selectedDialogue 
    ? lessons[selectedDialogue.lessonIndex].dialogues[selectedDialogue.dialogueIndex].words 
    : [];

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 via-yellow-50 to-orange-50 p-4 md:p-6">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="text-center mb-6">
          <h1 className="text-3xl md:text-4xl font-bold text-red-700 mb-2 flex items-center justify-center gap-2">
            <Sparkles className="w-7 h-7 md:w-8 md:h-8" />
            學習繁體中文
          </h1>
          <p className="text-gray-600">Lecciones 7 y 8 - Traditional Chinese</p>
          
          {/* User info and Rankings button */}
          <div className="mt-4 flex flex-col sm:flex-row items-center justify-center gap-3">
            {userName && (
              <div className="bg-white px-4 py-2 rounded-lg shadow-sm border border-red-200">
                <span className="text-sm text-gray-600">Usuario: </span>
                <span className="font-semibold text-red-700">{userName}</span>
              </div>
            )}
            <button
              onClick={() => setShowRankings(!showRankings)}
              className="bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white px-4 py-2 rounded-lg shadow-md transition-all flex items-center gap-2 font-medium"
            >
              <Trophy className="w-4 h-4" />
              {showRankings ? 'Ocultar Ranking' : 'Ver Ranking'}
            </button>
          </div>
        </div>

        {/* Rankings Table */}
        {showRankings && (
          <div className="bg-white rounded-xl shadow-lg p-4 md:p-6 mb-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Trophy className="w-6 h-6 text-yellow-500" />
                <h2 className="text-xl font-bold text-gray-800">Ranking de Estudiantes</h2>
              </div>
            </div>
            
            {rankings.length === 0 ? (
              <p className="text-center text-gray-500 py-8">No hay puntuaciones todavía. ¡Sé el primero!</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gradient-to-r from-red-50 to-orange-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Posición</th>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Nombre</th>
                      <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">Quizzes</th>
                      <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">Puntos Totales</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {rankings.map((user, index) => (
                      <tr key={index} className={`hover:bg-gray-50 ${index < 3 ? 'bg-yellow-50' : ''}`}>
                        <td className="px-4 py-3">
                          <div className="flex items-center gap-2">
                            {index === 0 && <span className="text-2xl">🥇</span>}
                            {index === 1 && <span className="text-2xl">🥈</span>}
                            {index === 2 && <span className="text-2xl">🥉</span>}
                            {index > 2 && <span className="font-medium text-gray-600">#{index + 1}</span>}
                          </div>
                        </td>
                        <td className="px-4 py-3 font-medium text-gray-800">{user.name}</td>
                        <td className="px-4 py-3 text-center text-gray-600">{user.quizzesCompleted}</td>
                        <td className="px-4 py-3 text-center">
                          <span className="font-bold text-red-600 text-lg">{user.totalScore}</span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* Home - Lesson Selector */}
        {mode === 'home' && (
          <div className="bg-white rounded-xl shadow-lg p-4 md:p-6">
            <div className="flex items-center gap-2 mb-6">
              <BookOpen className="w-5 h-5 text-red-600" />
              <h2 className="text-lg md:text-xl font-semibold text-gray-800">Selecciona una Lección</h2>
            </div>
            
            <div className="space-y-3">
              {lessons.map((lesson, lessonIndex) => (
                <div key={lessonIndex} className="border border-gray-200 rounded-lg overflow-hidden">
                  {/* Lesson Header */}
                  <button
                    onClick={() => toggleLesson(lessonIndex)}
                    className="w-full flex items-center justify-between p-4 bg-gradient-to-r from-red-50 to-orange-50 hover:from-red-100 hover:to-orange-100 transition-colors"
                  >
                    <span className="text-lg font-semibold text-gray-800">{lesson.lessonName}</span>
                    {expandedLesson === lessonIndex ? (
                      <ChevronDown className="w-5 h-5 text-red-600" />
                    ) : (
                      <ChevronRight className="w-5 h-5 text-red-600" />
                    )}
                  </button>
                  
                  {/* Dialogue Options */}
                  {expandedLesson === lessonIndex && (
                    <div className="p-3 bg-white space-y-2">
                      {lesson.dialogues.map((dialogue, dialogueIndex) => (
                        <button
                          key={dialogueIndex}
                          onClick={() => selectDialogue(lessonIndex, dialogueIndex)}
                          className="w-full text-left p-3 rounded-lg bg-gray-50 hover:bg-red-100 transition-colors border border-gray-200 hover:border-red-300"
                        >
                          <div className="font-medium text-gray-800">{dialogue.dialogueName}</div>
                          <div className="text-sm text-gray-500 mt-1">
                            {dialogue.words.length} palabras
                          </div>
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Learning Mode */}
        {mode === 'learn' && selectedDialogue && (
          <div className="bg-white rounded-xl shadow-lg p-4 md:p-8">
            <div className="mb-6">
              <button
                onClick={resetToHome}
                className="text-red-600 hover:text-red-700 font-medium mb-4 flex items-center gap-2"
              >
                ← Volver a Lecciones
              </button>
              <h2 className="text-xl md:text-2xl font-bold text-gray-800 text-center">
                {lessons[selectedDialogue.lessonIndex].lessonName} - {lessons[selectedDialogue.lessonIndex].dialogues[selectedDialogue.dialogueIndex].dialogueName}
              </h2>
            </div>
            
            <div className="space-y-3 md:space-y-4">
              {currentWords.map((word, index) => (
                <div
                  key={index}
                  className="bg-gradient-to-r from-red-50 to-orange-50 rounded-lg p-4 md:p-5 hover:shadow-md transition-shadow"
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-baseline gap-2 mb-2">
                        <div className="text-3xl md:text-4xl font-bold text-red-700">
                          {word.chinese}
                        </div>
                        {word.type && (
                          <span className="text-xs text-gray-500 font-medium">{word.type}</span>
                        )}
                      </div>
                      <div className="text-base md:text-lg text-gray-600 mb-1">{word.pinyin}</div>
                      <div className="text-sm md:text-base text-gray-700">{word.english}</div>
                    </div>
                    <button
                      onClick={() => speak(word.chinese)}
                      className="bg-red-600 hover:bg-red-700 text-white p-2 md:p-3 rounded-full transition-colors flex-shrink-0"
                    >
                      <Volume2 className="w-5 h-5 md:w-6 md:h-6" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
            <button
              onClick={startQuiz}
              className="w-full mt-6 bg-gradient-to-r from-red-600 to-orange-600 hover:from-red-700 hover:to-orange-700 text-white font-semibold py-3 md:py-4 rounded-lg transition-all shadow-md"
            >
              Hacer Quiz
            </button>
          </div>
        )}

        {/* Name Input Modal */}
        {showNameInput && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-xl shadow-2xl p-6 md:p-8 max-w-md w-full">
              <h3 className="text-2xl font-bold text-gray-800 mb-4 text-center">¡Ingresa tu Nombre!</h3>
              <p className="text-gray-600 mb-6 text-center">Para guardar tu puntuación en el ranking</p>
              <input
                type="text"
                value={userName}
                onChange={(e) => setUserName(e.target.value)}
                placeholder="Tu nombre"
                className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:border-red-500 focus:outline-none mb-4 text-lg"
                onKeyPress={(e) => {
                  if (e.key === 'Enter' && userName.trim()) {
                    setShowNameInput(false);
                    startQuiz();
                  }
                }}
                autoFocus
              />
              <div className="flex gap-3">
                <button
                  onClick={() => setShowNameInput(false)}
                  className="flex-1 bg-gray-300 hover:bg-gray-400 text-gray-800 font-semibold py-3 rounded-lg transition-colors"
                >
                  Cancelar
                </button>
                <button
                  onClick={() => {
                    if (userName.trim()) {
                      setShowNameInput(false);
                      startQuiz();
                    }
                  }}
                  disabled={!userName.trim()}
                  className="flex-1 bg-gradient-to-r from-red-600 to-orange-600 hover:from-red-700 hover:to-orange-700 text-white font-semibold py-3 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Comenzar Quiz
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Quiz Mode */}
        {mode === 'quiz' && selectedDialogue && (
          <div className="bg-white rounded-xl shadow-lg p-4 md:p-8">
            <div className="mb-6">
              <div className="flex justify-between items-center mb-2 text-sm md:text-base">
                <span className="text-gray-600">
                  Pregunta {currentQuiz + 1} de {currentWords.length}
                </span>
                <span className="text-red-600 font-semibold">Puntos: {score}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-red-600 h-2 rounded-full transition-all"
                  style={{ width: `${((currentQuiz + 1) / currentWords.length) * 100}%` }}
                />
              </div>
            </div>

            <div className="text-center mb-8">
              <div className="text-4xl md:text-5xl font-bold text-red-700 mb-2">
                {currentWords[currentQuiz].chinese}
              </div>
              <div className="text-base md:text-lg text-gray-500 mb-4">
                {currentWords[currentQuiz].pinyin}
              </div>
              <button
                onClick={() => speak(currentWords[currentQuiz].chinese)}
                className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg transition-colors text-sm md:text-base"
              >
                <Volume2 className="w-4 h-4 md:w-5 md:h-5 inline mr-2" />
                Escuchar
              </button>
              <p className="text-gray-600 mt-4 text-base md:text-lg">¿Qué significa esto?</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4 mb-6">
              {quizAnswers.map((answer, index) => (
                <button
                  key={index}
                  onClick={() => !showResult && handleAnswer(answer)}
                  disabled={showResult}
                  className={`p-3 md:p-4 rounded-lg font-medium transition-all text-sm md:text-base text-left ${
                    showResult
                      ? answer.chinese === currentWords[currentQuiz].chinese
                        ? 'bg-green-100 border-2 border-green-500 text-green-700'
                        : selectedAnswer?.chinese === answer.chinese
                        ? 'bg-red-100 border-2 border-red-500 text-red-700'
                        : 'bg-gray-100 text-gray-500'
                      : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span>{answer.english}</span>
                    {showResult && answer.chinese === currentWords[currentQuiz].chinese && (
                      <CheckCircle className="w-5 h-5 flex-shrink-0" />
                    )}
                    {showResult && selectedAnswer?.chinese === answer.chinese && answer.chinese !== currentWords[currentQuiz].chinese && (
                      <XCircle className="w-5 h-5 flex-shrink-0" />
                    )}
                  </div>
                </button>
              ))}
            </div>

            {showResult && (
              <button
                onClick={nextQuestion}
                className="w-full bg-red-600 hover:bg-red-700 text-white font-semibold py-3 md:py-4 rounded-lg transition-colors"
              >
                {currentQuiz < currentWords.length - 1 ? 'Siguiente Pregunta' : 'Ver Resultados'}
              </button>
            )}
          </div>
        )}

        {/* Results Mode */}
        {mode === 'results' && (
          <div className="bg-white rounded-xl shadow-lg p-6 md:p-8 text-center">
            <div className="text-5xl md:text-6xl mb-4">
              {score === currentWords.length ? '🎉' : score >= currentWords.length * 0.7 ? '👏' : '💪'}
            </div>
            <h2 className="text-2xl md:text-3xl font-bold text-gray-800 mb-2">¡Quiz Completado!</h2>
            <p className="text-4xl md:text-5xl font-bold text-red-600 my-6">
              {score} / {currentWords.length}
            </p>
            <p className="text-lg md:text-xl text-gray-600 mb-8">
              {score === currentWords.length
                ? '¡Perfecto! 太棒了！'
                : score >= currentWords.length * 0.7
                ? '¡Muy bien! ¡Sigue practicando!'
                : '¡Sigue aprendiendo! ¡Tú puedes!'}
            </p>
            <div className="flex flex-col sm:flex-row gap-3 md:gap-4">
              <button
                onClick={startQuiz}
                className="flex-1 bg-red-600 hover:bg-red-700 text-white font-semibold py-3 md:py-4 rounded-lg transition-colors flex items-center justify-center gap-2"
              >
                <RotateCcw className="w-5 h-5" />
                Repetir Quiz
              </button>
              <button
                onClick={resetQuiz}
                className="flex-1 bg-orange-600 hover:bg-orange-700 text-white font-semibold py-3 md:py-4 rounded-lg transition-colors flex items-center justify-center gap-2"
              >
                <BookOpen className="w-5 h-5" />
                Revisar Vocabulario
              </button>
              <button
                onClick={resetToHome}
                className="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-semibold py-3 md:py-4 rounded-lg transition-colors flex items-center justify-center gap-2"
              >
                Volver al Inicio
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ChineseLearningApp;