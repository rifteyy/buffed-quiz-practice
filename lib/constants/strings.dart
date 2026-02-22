enum AppLanguage { cs, en }

class AppStrings {
  static Map<String, String> _current = _cs;

  static AppLanguage _language = AppLanguage.cs;
  static AppLanguage get language => _language;

  static void setLanguage(AppLanguage lang) {
    _language = lang;
    _current = lang == AppLanguage.cs ? _cs : _en;
  }

  static String get(String key) => _current[key] ?? key;

  // Shorthand accessors
  static String get appName => get('appName');
  static String get home => get('home');
  static String get settings => get('settings');
  static String get history => get('history');
  static String get newQuiz => get('newQuiz');
  static String get editQuiz => get('editQuiz');
  static String get yourQuizzes => get('yourQuizzes');
  static String get sections => get('sections');
  static String get noQuizzesYet => get('noQuizzesYet');
  static String get noQuizzesDesc => get('noQuizzesDesc');
  static String get createQuiz => get('createQuiz');
  static String get start => get('start');
  static String get edit => get('edit');
  static String get delete => get('delete');
  static String get cancel => get('cancel');
  static String get save => get('save');
  static String get questions => get('questions');
  static String get question => get('question');
  static String get addQuestion => get('addQuestion');
  static String get addAnotherQuestion => get('addAnotherQuestion');
  static String get quizInfo => get('quizInfo');
  static String get quizName => get('quizName');
  static String get quizNameHint => get('quizNameHint');
  static String get descriptionOptional => get('descriptionOptional');
  static String get descriptionHint => get('descriptionHint');
  static String get timerMinutes => get('timerMinutes');
  static String get questionText => get('questionText');
  static String get questionTextHint => get('questionTextHint');
  static String get correctAnswer => get('correctAnswer');
  static String get correctAnswerHint => get('correctAnswerHint');
  static String get hintOptional => get('hintOptional');
  static String get hintForStudent => get('hintForStudent');
  static String get answerOptions => get('answerOptions');
  static String get aiGenerate => get('aiGenerate');
  static String get generating => get('generating');
  static String get multipleChoice => get('multipleChoice');
  static String get openEnded => get('openEnded');
  static String get option => get('option');
  static String get enterName => get('enterName');
  static String get enterValidTime => get('enterValidTime');
  static String get addAtLeastOneQuestion => get('addAtLeastOneQuestion');
  static String get fillQuestionAndAnswer => get('fillQuestionAndAnswer');
  static String get optionsGenerated => get('optionsGenerated');
  static String get setApiKeyFirst => get('setApiKeyFirst');
  static String get fillQuestionAndAnswerFirst => get('fillQuestionAndAnswerFirst');
  // Quiz screen
  static String get questionOf => get('questionOf');
  static String get completed => get('completed');
  static String get hint => get('hint');
  static String get next => get('next');
  static String get finish => get('finish');
  static String get finishQuiz => get('finishQuiz');
  static String get finishQuizConfirm => get('finishQuizConfirm');
  static String get continueQuiz => get('continueQuiz');
  static String get writeYourAnswer => get('writeYourAnswer');
  static String get confirmAnswer => get('confirmAnswer');
  static String get chooseFromAnswers => get('chooseFromAnswers');
  static String get apiKeyNeededForHint => get('apiKeyNeededForHint');
  // Results
  static String get results => get('results');
  static String get resultNotFound => get('resultNotFound');
  static String get answerOverview => get('answerOverview');
  static String get noAnswer => get('noAnswer');
  static String get yours => get('yours');
  static String get correct => get('correct');
  static String get aiFeedback => get('aiFeedback');
  static String get getAiFeedback => get('getAiFeedback');
  static String get generatingFeedback => get('generatingFeedback');
  static String get setApiKeyForFeedback => get('setApiKeyForFeedback');
  static String get homeBtn => get('homeBtn');
  static String get again => get('again');
  static String get time => get('time');
  // History
  static String get historyTitle => get('historyTitle');
  static String get noResultsYet => get('noResultsYet');
  static String get noResultsDesc => get('noResultsDesc');
  static String get deleteResult => get('deleteResult');
  static String get deleteResultConfirm => get('deleteResultConfirm');
  // Settings
  static String get openaiApiKey => get('openaiApiKey');
  static String get apiKeyDescription => get('apiKeyDescription');
  static String get apiKeySaved => get('apiKeySaved');
  static String get saveKey => get('saveKey');
  static String get aboutApp => get('aboutApp');
  static String get version => get('version');
  static String get aiModel => get('aiModel');
  static String get dataStorage => get('dataStorage');
  static String get localOnDevice => get('localOnDevice');
  static String get dangerZone => get('dangerZone');
  static String get deleteAllData => get('deleteAllData');
  static String get deleteAllDataConfirm => get('deleteAllDataConfirm');
  static String get allDataDeleted => get('allDataDeleted');
  static String get deleteAll => get('deleteAll');
  static String get languageSetting => get('languageSetting');
  static String get czech => get('czech');
  static String get english => get('english');
  // Delete quiz
  static String get deleteQuiz => get('deleteQuiz');
  static String get deleteQuizConfirm => get('deleteQuizConfirm');
  // Grades
  static String get gradeExcellent => get('gradeExcellent');
  static String get gradeVeryGood => get('gradeVeryGood');
  static String get gradeGood => get('gradeGood');
  static String get gradeSufficient => get('gradeSufficient');
  static String get gradeInsufficient => get('gradeInsufficient');
  // Quiz
  static String get min => get('min');
  // Shuffle
  static String get shuffleQuestions => get('shuffleQuestions');
  static String get shuffleQuestionsDesc => get('shuffleQuestionsDesc');
  static String get tapOptionToMarkCorrect => get('tapOptionToMarkCorrect');
  // Appearance
  static String get appearance => get('appearance');
  static String get themeColor => get('themeColor');
  static String get darkMode => get('darkMode');
  static String get colorSalmon => get('colorSalmon');
  static String get colorPurple => get('colorPurple');
  static String get colorBlue => get('colorBlue');
  static String get colorTeal => get('colorTeal');
  static String get colorOrange => get('colorOrange');
  static String get colorPink => get('colorPink');
  static String get colorGreen => get('colorGreen');
  static String get colorIndigo => get('colorIndigo');

  static const Map<String, String> _cs = {
    'appName': 'Buffed Quiz Practice',
    'home': 'Domů',
    'settings': 'Nastavení',
    'history': 'Historie',
    'newQuiz': 'Nový kvíz',
    'editQuiz': 'Upravit kvíz',
    'yourQuizzes': 'Vaše kvízy',
    'sections': 'sekcí',
    'noQuizzesYet': 'Zatím nemáte žádné kvízy',
    'noQuizzesDesc': 'Vytvořte si svůj první kvíz a začněte procvičovat!',
    'createQuiz': 'Vytvořit kvíz',
    'start': 'Spustit',
    'edit': 'Upravit',
    'delete': 'Smazat',
    'cancel': 'Zrušit',
    'save': 'Uložit',
    'questions': 'otázek',
    'question': 'Otázka',
    'addQuestion': 'Přidat',
    'addAnotherQuestion': 'Přidat další otázku',
    'quizInfo': 'Informace o kvízu',
    'quizName': 'Název kvízu',
    'quizNameHint': 'např. Dějepis - 2. světová válka',
    'descriptionOptional': 'Popis (volitelné)',
    'descriptionHint': 'Krátký popis učiva',
    'timerMinutes': 'Časový limit (minuty)',
    'questionText': 'Text otázky',
    'questionTextHint': 'Zadejte otázku...',
    'correctAnswer': 'Správná odpověď',
    'correctAnswerHint': 'Zadejte správnou odpověď...',
    'hintOptional': 'Nápověda (volitelné)',
    'hintForStudent': 'Nápověda pro studenta...',
    'answerOptions': 'Možnosti odpovědí',
    'aiGenerate': 'AI generovat',
    'generating': 'Generuji...',
    'multipleChoice': 'A-D',
    'openEnded': 'Psaná',
    'option': 'Možnost',
    'enterName': 'Zadejte název',
    'enterValidTime': 'Zadejte platný čas',
    'addAtLeastOneQuestion': 'Přidejte alespoň jednu otázku',
    'fillQuestionAndAnswer': 'Vyplňte otázku a odpověď u otázky',
    'optionsGenerated': 'Odpovědi vygenerovány',
    'setApiKeyFirst': 'Nejprve nastavte API klíč v Nastavení',
    'fillQuestionAndAnswerFirst': 'Vyplňte otázku a správnou odpověď',
    'questionOf': 'Otázka',
    'completed': 'dokončeno',
    'hint': 'Nápověda',
    'next': 'Další',
    'finish': 'Dokončit',
    'finishQuiz': 'Ukončit kvíz?',
    'finishQuizConfirm': 'Chcete kvíz ukončit?',
    'continueQuiz': 'Pokračovat',
    'writeYourAnswer': 'Napište svou odpověď...',
    'confirmAnswer': 'Potvrdit odpověď',
    'chooseFromAnswers': 'Výběr z odpovědí',
    'apiKeyNeededForHint': 'Pro AI nápovědu nastavte API klíč v Nastavení',
    'results': 'Výsledky',
    'resultNotFound': 'Výsledek nenalezen',
    'answerOverview': 'Přehled odpovědí',
    'noAnswer': '(bez odpovědi)',
    'yours': 'Vaše',
    'correct': 'Správně',
    'aiFeedback': 'AI zpětná vazba',
    'getAiFeedback': 'Získat AI zpětnou vazbu',
    'generatingFeedback': 'Generuji zpětnou vazbu...',
    'setApiKeyForFeedback': 'Nastavte API klíč v Nastavení pro AI zpětnou vazbu',
    'homeBtn': 'Domů',
    'again': 'Znovu',
    'time': 'Čas',
    'historyTitle': 'Historie výsledků',
    'noResultsYet': 'Zatím žádné výsledky',
    'noResultsDesc': 'Dokončete kvíz a vaše výsledky se zde zobrazí.',
    'deleteResult': 'Smazat výsledek',
    'deleteResultConfirm': 'Smazat výsledek pro',
    'openaiApiKey': 'OpenAI API klíč',
    'apiKeyDescription':
        'Pro AI funkce (generování odpovědí, zpětná vazba, nápovědy) zadejte svůj OpenAI API klíč. Klíč je uložen pouze lokálně na vašem zařízení.',
    'apiKeySaved': 'API klíč uložen',
    'saveKey': 'Uložit klíč',
    'aboutApp': 'O aplikaci',
    'version': 'Verze',
    'aiModel': 'AI model',
    'dataStorage': 'Data',
    'localOnDevice': 'Lokálně na zařízení',
    'dangerZone': 'Nebezpečná zóna',
    'deleteAllData': 'Smazat všechna data',
    'deleteAllDataConfirm':
        'Tím smažete všechny kvízy, výsledky a nastavení. Tato akce je nevratná.',
    'allDataDeleted': 'Všechna data smazána',
    'deleteAll': 'Smazat vše',
    'languageSetting': 'Jazyk',
    'czech': 'Čeština',
    'english': 'English',
    'deleteQuiz': 'Smazat kvíz',
    'deleteQuizConfirm': 'Opravdu chcete smazat kvíz',
    'gradeExcellent': '1 (Výborný)',
    'gradeVeryGood': '2 (Chvalitebný)',
    'gradeGood': '3 (Dobrý)',
    'gradeSufficient': '4 (Dostatečný)',
    'gradeInsufficient': '5 (Nedostatečný)',
    'min': 'min',
    'shuffleQuestions': 'Náhodné pořadí otázek',
    'shuffleQuestionsDesc': 'Otázky se zamíchají při každém spuštění',
    'tapOptionToMarkCorrect': 'Klikněte na písmeno pro označení správné odpovědi',
    'appearance': 'Vzhled',
    'themeColor': 'Barva tématu',
    'darkMode': 'Tmavý režim',
    'colorSalmon': 'Lososová',
    'colorPurple': 'Fialová',
    'colorBlue': 'Modrá',
    'colorTeal': 'Tyrkysová',
    'colorOrange': 'Oranžová',
    'colorPink': 'Růžová',
    'colorGreen': 'Zelená',
    'colorIndigo': 'Indigo',
  };

  static const Map<String, String> _en = {
    'appName': 'Buffed Quiz Practice',
    'home': 'Home',
    'settings': 'Settings',
    'history': 'History',
    'newQuiz': 'New Quiz',
    'editQuiz': 'Edit Quiz',
    'yourQuizzes': 'Your Quizzes',
    'sections': 'sections',
    'noQuizzesYet': 'No quizzes yet',
    'noQuizzesDesc': 'Create your first quiz and start practicing!',
    'createQuiz': 'Create Quiz',
    'start': 'Start',
    'edit': 'Edit',
    'delete': 'Delete',
    'cancel': 'Cancel',
    'save': 'Save',
    'questions': 'questions',
    'question': 'Question',
    'addQuestion': 'Add',
    'addAnotherQuestion': 'Add another question',
    'quizInfo': 'Quiz Information',
    'quizName': 'Quiz Name',
    'quizNameHint': 'e.g. History - World War II',
    'descriptionOptional': 'Description (optional)',
    'descriptionHint': 'Short description of the topic',
    'timerMinutes': 'Time limit (minutes)',
    'questionText': 'Question text',
    'questionTextHint': 'Enter question...',
    'correctAnswer': 'Correct answer',
    'correctAnswerHint': 'Enter correct answer...',
    'hintOptional': 'Hint (optional)',
    'hintForStudent': 'Hint for student...',
    'answerOptions': 'Answer options',
    'aiGenerate': 'AI generate',
    'generating': 'Generating...',
    'multipleChoice': 'A-D',
    'openEnded': 'Written',
    'option': 'Option',
    'enterName': 'Enter name',
    'enterValidTime': 'Enter valid time',
    'addAtLeastOneQuestion': 'Add at least one question',
    'fillQuestionAndAnswer': 'Fill in question and answer for question',
    'optionsGenerated': 'Options generated',
    'setApiKeyFirst': 'Set your API key in Settings first',
    'fillQuestionAndAnswerFirst': 'Fill in the question and correct answer',
    'questionOf': 'Question',
    'completed': 'completed',
    'hint': 'Hint',
    'next': 'Next',
    'finish': 'Finish',
    'finishQuiz': 'Finish quiz?',
    'finishQuizConfirm': 'Do you want to finish the quiz?',
    'continueQuiz': 'Continue',
    'writeYourAnswer': 'Write your answer...',
    'confirmAnswer': 'Confirm answer',
    'chooseFromAnswers': 'Multiple choice',
    'apiKeyNeededForHint': 'Set your API key in Settings for AI hints',
    'results': 'Results',
    'resultNotFound': 'Result not found',
    'answerOverview': 'Answer Overview',
    'noAnswer': '(no answer)',
    'yours': 'Yours',
    'correct': 'Correct',
    'aiFeedback': 'AI Feedback',
    'getAiFeedback': 'Get AI Feedback',
    'generatingFeedback': 'Generating feedback...',
    'setApiKeyForFeedback': 'Set your API key in Settings for AI feedback',
    'homeBtn': 'Home',
    'again': 'Again',
    'time': 'Time',
    'historyTitle': 'Result History',
    'noResultsYet': 'No results yet',
    'noResultsDesc': 'Complete a quiz and your results will appear here.',
    'deleteResult': 'Delete result',
    'deleteResultConfirm': 'Delete result for',
    'openaiApiKey': 'OpenAI API Key',
    'apiKeyDescription':
        'For AI features (answer generation, feedback, hints) enter your OpenAI API key. The key is stored locally on your device only.',
    'apiKeySaved': 'API key saved',
    'saveKey': 'Save key',
    'aboutApp': 'About',
    'version': 'Version',
    'aiModel': 'AI model',
    'dataStorage': 'Data',
    'localOnDevice': 'Locally on device',
    'dangerZone': 'Danger Zone',
    'deleteAllData': 'Delete all data',
    'deleteAllDataConfirm':
        'This will delete all quizzes, results, and settings. This action is irreversible.',
    'allDataDeleted': 'All data deleted',
    'deleteAll': 'Delete all',
    'languageSetting': 'Language',
    'czech': 'Čeština',
    'english': 'English',
    'deleteQuiz': 'Delete quiz',
    'deleteQuizConfirm': 'Are you sure you want to delete quiz',
    'gradeExcellent': '1 (Excellent)',
    'gradeVeryGood': '2 (Very Good)',
    'gradeGood': '3 (Good)',
    'gradeSufficient': '4 (Sufficient)',
    'gradeInsufficient': '5 (Insufficient)',
    'min': 'min',
    'shuffleQuestions': 'Shuffle questions',
    'shuffleQuestionsDesc': 'Questions will be shuffled on each quiz start',
    'tapOptionToMarkCorrect': 'Tap the letter to mark the correct answer',
    'appearance': 'Appearance',
    'themeColor': 'Theme Color',
    'darkMode': 'Dark Mode',
    'colorSalmon': 'Salmon',
    'colorPurple': 'Purple',
    'colorBlue': 'Blue',
    'colorTeal': 'Teal',
    'colorOrange': 'Orange',
    'colorPink': 'Pink',
    'colorGreen': 'Green',
    'colorIndigo': 'Indigo',
  };
}
