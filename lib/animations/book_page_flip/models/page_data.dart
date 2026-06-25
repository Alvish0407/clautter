class PageData {
  final String? headerLeft;
  final String? headerRight;
  final String body;
  final int pageNumber;

  const PageData({
    this.headerLeft,
    this.headerRight,
    required this.body,
    required this.pageNumber,
  });
}

// "The Book of Tea" by Kakuzo Okakura (public domain).
const List<PageData> kBookPages = [
  // Spread 1: pages 1-2 (index 0,1)
  PageData(
    headerLeft: 'THE BOOK OF TEA',
    body: '',
    pageNumber: 1,
  ),
  PageData(
    headerRight: 'I. THE CUP OF HUMANITY',
    body: 'Tea began as a medicine and grew into a beverage. '
        'In China, in the eighth century, it entered the realm '
        'of poetry as one of the polite amusements. The fifteenth '
        'century saw Japan ennoble it into a religion of '
        'aestheticism—Teaism. Teaism is a cult founded on the '
        'adoration of the beautiful among the sordid facts of '
        'everyday existence. It inculcates purity and harmony, '
        'the mystery of mutual charity, the romanticism of the '
        'social order. It is essentially a worship of the Imperfect, '
        'as it is a tender attempt to accomplish something possible '
        'in this impossible thing we know as life.',
    pageNumber: 2,
  ),
  // Spread 2: pages 3-4 (index 2,3)
  PageData(
    headerLeft: 'THE BOOK OF TEA',
    body: 'The Philosophy of Tea is not mere aestheticism '
        'in the ordinary acceptance of the term, for it expresses '
        'conjointly with ethics and religion our whole point of '
        'view about man and nature. It is hygiene, for it enforces '
        'cleanliness; it is economics, for it shows comfort in '
        'simplicity rather than in the complex and costly; it is '
        'moral geometry, inasmuch as it defines our sense of '
        'proportion to the universe. It represents the true spirit '
        'of Eastern democracy by making all its votaries aristocrats '
        'in taste.',
    pageNumber: 3,
  ),
  PageData(
    headerRight: 'I. THE CUP OF HUMANITY',
    body: 'Those who cannot feel the littleness of great things '
        'in themselves are apt to overlook the greatness of little '
        'things in others. The average Westerner, in his sleek '
        'complacency, will see in the tea ceremony but another '
        'instance of the thousand and one oddities which constitute '
        'the quaintness and childishness of the East to him. He was '
        'wont to regard Japan as barbarous while she indulged in the '
        'gentle arts of peace: he calls her civilised since she began '
        'to commit wholesale slaughter on Manchurian battlefields.',
    pageNumber: 4,
  ),
  // Spread 3: pages 5-6 (index 4,5)
  PageData(
    headerLeft: 'THE BOOK OF TEA',
    body: 'Why not amuse yourselves at our expense? Asia returns '
        'the compliment. There would be further food for merriment '
        'if you were to know all that we have imagined and written '
        'about you. All the glamour of the perspective is there, '
        'all the unconscious homage of wonder, all the silent '
        'resentment of the new and undefined. You have been loaded '
        'with virtues too refined to be envied, and accused of crimes '
        'too picturesque to be condemned. Our writers in the past—'
        'the wise men who knew—informed us that you had bushy tails '
        'somewhere hidden in your garments.',
    pageNumber: 5,
  ),
  PageData(
    headerRight: 'I. THE CUP OF HUMANITY',
    body: 'Such misconceptions are fast vanishing amongst us. '
        'Commerce has forced the European tongues on many an Eastern '
        'port. Asiatic youths are flocking to Western colleges for '
        'the equipment of modern education. Our insight does not '
        'penetrate your culture deeply, but at least we are willing '
        'to learn. Some of my compatriots have adopted too much of '
        'your customs and too much of your etiquette, in the delusion '
        'that the acquisition of stiff collars and tall silk hats '
        'comprised the attainment of your civilisation.',
    pageNumber: 6,
  ),
  // Spread 4: pages 7-8 (index 6,7)
  PageData(
    headerLeft: 'THE BOOK OF TEA',
    body: 'Strangely enough humanity has so far met in the tea-cup. '
        'It is the only Asiatic ceremonial which commands universal '
        'esteem. The white man has scoffed at our religion and our '
        'morals, but has accepted the brown beverage without hesitation. '
        'The afternoon tea is now an important function in Western '
        'society. In the delicate clatter of trays and saucers, in '
        'the soft rustle of feminine hospitality, in the common '
        'catechism about cream and sugar, we know that the Worship '
        'of Tea is established beyond question.',
    pageNumber: 7,
  ),
  PageData(
    headerRight: 'I. THE CUP OF HUMANITY',
    body: 'The earliest record of tea in European writing is said '
        'to be found in the statement of an Arabian traveller, that '
        'after the year 879 the main sources of revenue in Canton '
        'were the duties on salt and tea. Marco Polo records the '
        'deposition of a Chinese minister of finance in 1285 for '
        'his arbitrary augmentation of the tea-taxes. It was at the '
        'period of the great discoveries that the European people '
        'began to know more about the extreme Orient. At the end '
        'of the sixteenth century the Hollanders brought the news '
        'that a pleasant drink was made in the East from the '
        'leaves of a bush.',
    pageNumber: 8,
  ),
];
