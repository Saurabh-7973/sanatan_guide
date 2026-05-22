import 'package:sanatan_guide/domain/entities/festival.dart';

/// Festival dates verified against Drik Panchang (drikpanchang.com)
/// for New Delhi, India on April 14, 2026.
///
/// Ram Navami uses the Smarta date (Chaitra Shukla Navami).
/// Janmashtami uses the Smarta date (Bhadrapada Krishna Ashtami).
/// For festivals with regional variations (Purnimant vs Amant calendars),
/// the North Indian (Purnimant) date is used.
final List<Festival> festivals2026 = [
  Festival(
    id: 'makar_sankranti',
    name: 'Makar Sankranti',
    sanskritName: 'मकर संक्रान्ति',
    date: DateTime(2026, 1, 14),
    shortDesc: 'The sun enters Capricorn — a day of gratitude and giving',
    deity: 'Surya',
    emoji: '☀️',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Wake before sunrise and take a bath — ideally in a river or with sesame (til) mixed in the water.',
      'Offer water to the rising sun (Surya Arghya) while reciting the Gayatri Mantra or Om Suryaya Namah.',
      'Prepare or obtain til-gur (sesame and jaggery) — share it with family, friends, and neighbours.',
      'Donate til, blankets, or warm food to those in need — dana on this day carries special significance.',
      'Light a lamp at home and offer gratitude for the return of longer days and the sun\'s northern journey.',
    ],
    explainer:
        'Makar Sankranti marks the moment the Sun (Surya) transitions into '
        'Capricorn (Makara), ending the inauspicious Dakshinayana period and '
        'beginning Uttarayana — the six-month northern journey of the sun.\n\n'
        'In dharmic cosmology, Uttarayana is the "day of the gods". Those who '
        'die during this period are believed to attain moksha more easily. '
        'Bhishma Pitamaha in the Mahabharata waited on his bed of arrows for '
        'Uttarayana before leaving his body.\n\n'
        'The festival is celebrated differently across Bharat: as Pongal in '
        'Tamil Nadu, Lohri in Punjab, Bihu in Assam, and Uttarayan in Gujarat '
        'where kite-flying fills the skies. Common across all forms: sesame '
        'seeds (til) and jaggery (gur) are shared as prasad, symbolising the '
        'sweetness of togetherness and the warmth needed in winter.',
  ),
  Festival(
    id: 'maha_shivratri',
    name: 'Maha Shivratri',
    sanskritName: 'महाशिवरात्रि',
    date: DateTime(2026, 2, 15),
    shortDesc: 'The great night of Shiva — fasting, vigil, and transformation',
    deity: 'Shiva',
    emoji: '🔱',
    category: FestivalCategory.vrat,
    howToObserve: const [
      'Fast through the day — water, fruits, and milk are permitted. Full fast is traditional but partial is accepted.',
      'Perform abhisheka (ritual bathing) of the Shivalinga with milk, honey, water, and bel leaves.',
      'Chant Om Namah Shivaya throughout the day and especially through the night.',
      'Stay awake through the night (jaagaran) — the four praharas (3-hour watches) each have special significance.',
      'Break the fast the following morning after morning puja, ideally with prasad from the temple.',
    ],
    explainer:
        'Maha Shivratri — the Great Night of Shiva — falls on the 14th night '
        'of the dark fortnight in Phalguna. It is considered the most '
        'auspicious night to worship Shiva, and the one night when he is '
        'closest to his devotees.\n\n'
        'The tradition involves an all-night vigil (jaagaran), fasting, and '
        'the rhythmic chanting of Om Namah Shivaya. Shivalingas are bathed '
        'with milk, honey, and water in the ritual called abhisheka.\n\n'
        'The mythological significance varies: some traditions say this is the '
        'night Shiva performed the cosmic dance Tandava. Others say it marks '
        'Shiva and Parvati\'s wedding. Yogically, it is the night when the '
        'planetary positions naturally help spiritual seekers transcend their '
        'ordinary consciousness — which is why sadhana done on this night is '
        'said to yield results far beyond any ordinary night.',
  ),
  Festival(
    id: 'holi',
    name: 'Holi',
    sanskritName: 'होली',
    date: DateTime(2026, 3, 4),
    shortDesc: 'The festival of colours — victory of devotion over arrogance',
    deity: 'Vishnu',
    emoji: '🎨',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'The night before Holi, attend or witness Holika Dahan — the bonfire that commemorates Prahlada\'s devotion.',
      'Walk around the bonfire (parikrama) and offer prayer, remembering what you wish to burn away this year.',
      'On Holi morning, play colours with family and friends — traditionally natural colours from flowers were used.',
      'Prepare or share gujiya, thandai, and seasonal sweets as prasad.',
      'In the evening, visit elders and exchange greetings — Holi dissolves social hierarchies for one day.',
    ],
    explainer:
        'Holi is celebrated on the full moon of Phalguna. The night before, '
        'Holika Dahan — a bonfire — is lit across Bharat, commemorating the '
        'story of Prahlada and Holika.\n\n'
        'Prahlada, a devoted child of Vishnu, was despised by his own father '
        'Hiranyakashipu, an asura who demanded worship for himself. Holika, '
        'his sister, had a boon of being fireproof. She sat with Prahlada in '
        'a bonfire to kill him — but devotion to Vishnu protected Prahlada '
        'while Holika burned. The bonfire commemorates this.\n\n'
        'The colours of Holi were originally from flowers and herbs, each '
        'with medicinal properties to ease the body into spring. The '
        'celebration dissolves social barriers — caste, class, age — in a '
        'shared expression of joy and renewal.',
  ),
  Festival(
    id: 'ram_navami',
    name: 'Ram Navami',
    sanskritName: 'राम नवमी',
    date: DateTime(2026, 3, 26),
    shortDesc: 'The birth of Rama — the ideal of dharmic kingship',
    deity: 'Rama',
    emoji: '🏹',
    category: FestivalCategory.vrat,
    howToObserve: const [
      'Fast through the day or take a single meal — fruits and milk are traditionally permitted.',
      'Read or listen to the Sundara Kanda of the Valmiki Ramayana, or the Ram Charit Manas.',
      'Chant the Ram naam — "Shri Ram Jai Ram Jai Jai Ram" — 108 times or more.',
      'At noon (Rama\'s birth time), perform puja with a murti or image of Rama, offering flowers, tulsi, and prasad.',
      'Visit a Rama temple if possible, or organise a home recitation of Ram Katha with family.',
    ],
    explainer:
        'Ram Navami falls on the ninth day (navami) of Chaitra Shukla paksha '
        '— the ninth day of the bright fortnight of the first month of the '
        'Hindu calendar. It marks the birth of Rama, the seventh avatar of '
        'Vishnu, born to King Dasharatha and Queen Kaushalya of Ayodhya.\n\n'
        'Rama represents the ideal man — Maryada Purushottama, the supreme '
        'upholder of limits. His life demonstrates that dharma is not merely '
        'following rules but living them fully even at personal cost.\n\n'
        'The Ramayana is not mythology in the Western sense — it is a map of '
        'the human psyche. Sita is the soul, Rama is the divine self, Ravana '
        'is the ego, and Hanuman is the devoted breath that bridges them. The '
        'day is observed with fasting, reading of the Ramayana, and recitation '
        'of Ram naam.',
  ),
  Festival(
    id: 'hanuman_jayanti',
    name: 'Hanuman Jayanti',
    sanskritName: 'हनुमान जयंती',
    date: DateTime(2026, 4, 2),
    shortDesc: 'Birth of Hanuman — the embodiment of seva and strength',
    deity: 'Hanuman',
    emoji: '🙏',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Recite the Hanuman Chalisa — ideally at sunrise. If possible, complete 7 or 11 recitations.',
      'Offer red flowers, sindoor (vermillion), and sesame oil at a Hanuman temple or home altar.',
      'Fast through the day or take a single sattvic meal without onion or garlic.',
      'Read the Sundara Kanda of the Ramayana — the chapter where Hanuman crosses the ocean and finds Sita.',
      'Perform seva — any selfless act of service. Hanuman\'s essence is action without ego.',
    ],
    explainer:
        'Hanuman Jayanti celebrates the birth of Hanuman, the vanara warrior '
        'and the perfect devotee of Rama. Born to Anjana and Kesari, blessed '
        'by Vayu (the wind god), Hanuman represents the pinnacle of bhakti '
        'combined with extraordinary power.\n\n'
        'Hanuman is unique among Hindu deities: he is simultaneously the '
        'strongest being in the cosmos and the most humble servant. He has no '
        'ego — his immense shakti is entirely dedicated to Rama\'s purpose. '
        'He is the model of karma yoga: total action without attachment.\n\n'
        'The Hanuman Chalisa — 40 verses composed by Tulsidas — is recited '
        'on this day across Bharat. It is one of the most powerful stotras '
        'in the tradition, condensing the entire Hanuman principle into 40 '
        'precisely composed dohas and chaupais.',
  ),
  Festival(
    id: 'guru_purnima',
    name: 'Guru Purnima',
    sanskritName: 'गुरु पूर्णिमा',
    date: DateTime(2026, 7, 29),
    shortDesc:
        'Full moon of the Guru — gratitude for the one who removes darkness',
    deity: 'Vyasa',
    emoji: '🌕',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Rise early and begin the day with study — read a passage from a text given or recommended by your Guru.',
      'If you have a living Guru, offer pranam and express gratitude in person, by letter, or in prayer.',
      'Perform Vyasa Puja — offer flowers, incense, and a lamp to an image or representation of Veda Vyasa.',
      'Fast or take a light meal, keeping the mind clear for study, meditation, or satsang.',
      'Sit in silence for at least one hour and reflect: what teaching has most changed the direction of your life?',
    ],
    explainer:
        'Guru Purnima falls on the full moon of Ashadha. It is dedicated to '
        'Veda Vyasa — the sage who compiled the Vedas, wrote the 18 Puranas, '
        'and composed the Mahabharata. He is considered the Adi Guru, the '
        'first teacher.\n\n'
        'The word Guru is composed of two syllables: gu meaning darkness, and '
        'ru meaning the one who dispels. The Guru is not merely a teacher of '
        'information but one who removes the fundamental darkness of ignorance '
        'about one\'s own nature.\n\n'
        'This is also the day when the Buddha gave his first discourse at '
        'Sarnath, making it sacred across dharmic traditions. It is a day to '
        'honour all teachers — living or not — whose transmission has changed '
        'your direction.',
  ),
  Festival(
    id: 'janmashtami',
    name: 'Janmashtami',
    sanskritName: 'जन्माष्टमी',
    date: DateTime(2026, 9, 4),
    shortDesc: 'Birth of Krishna — the complete avatar',
    deity: 'Krishna',
    emoji: '🦚',
    category: FestivalCategory.vrat,
    howToObserve: const [
      'Fast through the day — breaking only after midnight when Krishna is born.',
      'Decorate a small cradle (jhula) with flowers and place a baby Krishna murti in it.',
      'At midnight, bathe the murti with panchamrita (milk, curd, honey, ghee, sugar), then dress it.',
      'Sing bhajans — especially Hare Krishna mahamantra — and read from the Bhagavata Purana, Book 10.',
      'After midnight puja, break the fast with prasad. Offer makhan (butter) and mishri — Krishna\'s favourites.',
    ],
    explainer:
        'Janmashtami celebrates the birth of Krishna, the eighth avatar of '
        'Vishnu, at midnight on the eighth day of the dark fortnight of '
        'Shravana. Krishna was born in a prison cell to Devaki and Vasudeva '
        'while the tyrant Kamsa slept — spirit enters the world in '
        'confinement but cannot be contained.\n\n'
        'Krishna is considered the purna avatar — the complete descent. Every '
        'dimension of human experience is encompassed in his life: the playful '
        'child, the romantic youth, the statesman, the warrior, the teacher. '
        'The Bhagavad Gita — spoken by Krishna on a battlefield — is '
        'considered the most concentrated dharmic text in existence.\n\n'
        'Temples stay open all night. At midnight, a murti of baby Krishna is '
        'bathed and rocked in a cradle. Dahi Handi — human pyramids breaking '
        'a pot of yogurt — celebrates the legend of Krishna stealing butter '
        'from the village women.',
  ),
  Festival(
    id: 'ganesh_chaturthi',
    name: 'Ganesh Chaturthi',
    sanskritName: 'गणेश चतुर्थी',
    date: DateTime(2026, 9, 14),
    shortDesc: 'Birthday of Ganesha — remover of obstacles, lord of beginnings',
    deity: 'Ganesha',
    emoji: '🐘',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Install a clay Ganesha murti at home or join the community installation — eco-friendly clay is traditional.',
      'Offer durva grass (21 blades), red flowers, modak (sweet dumplings), and coconut to Ganesha.',
      'Recite the Ganesha Atharvashirsha or Ganesha Sahasranama — both are specifically for this occasion.',
      'Keep the murti for 1.5, 5, 7, or 10 days based on tradition. Perform daily aarti morning and evening.',
      'On the final day, take the murti for visarjan (immersion) in a river, lake, or bucket of water at home.',
    ],
    explainer:
        'Ganesh Chaturthi marks the birthday of Ganesha, the elephant-headed '
        'son of Shiva and Parvati, on the fourth day of the bright fortnight '
        'of Bhadrapada. The festival lasts 10 days, culminating in Anant '
        'Chaturdashi when Ganesha murtis are immersed in water.\n\n'
        'Ganesha is Vighnaharta — the remover of obstacles — and is invoked '
        'at the start of every undertaking. His elephant head symbolises '
        'wisdom and memory; his large belly, the capacity to digest all of '
        'life\'s experiences; his broken tusk, the willingness to sacrifice '
        'one\'s own completeness for a higher purpose.\n\n'
        'The festival as a public celebration was expanded by Bal Gangadhar '
        'Tilak in 1893 as a way to unite Indians across caste during the '
        'freedom movement — making Ganesha Chaturthi as much a story of '
        'dharma meeting politics as of devotion.',
  ),
  Festival(
    id: 'navratri',
    name: 'Navratri',
    sanskritName: 'नवरात्रि',
    date: DateTime(2026, 10, 11),
    shortDesc:
        'Nine nights of the Goddess — the battle of consciousness over inertia',
    deity: 'Durga',
    emoji: '🪔',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Fast for all nine days or on alternate days — fruits, milk, and sendha namak (rock salt) are permitted.',
      'Set up a Devi altar with an image of Durga, Lakshmi, or Saraswati. Light a lamp (akhand jyot) if possible.',
      'Recite the Devi Mahatmyam (Durga Saptashati) — 700 verses divided across the nine days.',
      'On the eighth or ninth day (Ashtami or Navami), perform Kanya Puja — worship young girls as forms of the Devi.',
      'Break the fast on Vijayadashami (Dussehra) after morning puja, with prasad shared with family.',
    ],
    explainer: 'Navratri — nine nights — is the great festival of Shakti, the '
        'divine feminine principle. The Sharada Navratri in Ashwin is the '
        'most celebrated. Each of the nine nights is dedicated to a different '
        'form of the Goddess: from Shailaputri on the first night to Siddhidatri '
        'on the ninth.\n\n'
        'The underlying narrative is the Devi Mahatmyam: the story of Mahishasura, '
        'the buffalo demon who represented tamas — inertia, darkness, the refusal '
        'to evolve. The Goddess Durga, assembled from the combined shakti of all '
        'the gods, fought and destroyed him over nine nights.\n\n'
        'The nine forms correspond to nine aspects of consciousness moving from '
        'raw creative power through to perfected wisdom. It culminates in '
        'Vijayadashami — Dussehra — the day of victory.',
  ),
  Festival(
    id: 'dussehra',
    name: 'Dussehra',
    sanskritName: 'दशहरा',
    date: DateTime(2026, 10, 20),
    shortDesc: 'Victory of Rama over Ravana — the triumph of dharma',
    deity: 'Rama',
    emoji: '🏹',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Begin the day with Ram naam japa — recite "Shri Ram Jai Ram Jai Jai Ram" 108 times.',
      'Read or listen to the Yuddha Kanda of the Ramayana — the battle and victory of Rama.',
      'In the evening, attend or witness the burning of Ravana effigies — and consciously name one inner Ravana you will burn.',
      'Perform Shastra Puja if you work with tools, instruments, or vehicles — offer gratitude for the means of your work.',
      'Wear new clothes and exchange sweets — Vijayadashami is auspicious for beginning new ventures.',
    ],
    explainer:
        'Dussehra — also called Vijayadashami — is celebrated on the tenth '
        'day of Navratri, the day Rama is said to have defeated and killed '
        'Ravana. Effigies of Ravana, his brother Kumbhakarna, and son '
        'Meghnad are burned across Bharat in massive celebrations.\n\n'
        'Ravana is one of the most complex figures in Dharmic literature. '
        'He was a Brahmin, a great scholar, a devoted worshipper of Shiva, '
        'a gifted musician — and a king who used all his gifts in service of '
        'his own ego. His ten heads represent ten negative qualities: '
        'kama (lust), krodha (anger), moha (delusion), lobha (greed), '
        'mada (pride), matsarya (envy), manas (mind), buddhi (intellect), '
        'chitta (will), and ahamkara (ego).\n\n'
        'Burning Ravana is not about destroying an enemy. It is a ritual '
        'reminder to burn the Ravana within.',
  ),
  Festival(
    id: 'diwali',
    name: 'Diwali',
    sanskritName: 'दीपावली',
    date: DateTime(2026, 11, 8),
    shortDesc:
        'Festival of lights — the return of light after the darkest night',
    deity: 'Lakshmi',
    emoji: '🪔',
    category: FestivalCategory.majorParva,
    howToObserve: const [
      'Clean and declutter your home in the days before Diwali — Lakshmi does not enter homes of disorder.',
      'On Diwali evening, light diyas (clay lamps) with ghee or sesame oil — at least 13 around the home.',
      'Perform Lakshmi Puja after sunset: offer lotus flowers, coins, sweets, and recite Shri Suktam.',
      'Light diyas at the entrance, in each room, and on windowsills — the light guides Rama home and welcomes Lakshmi.',
      'Share sweets and gifts with neighbours, colleagues, and those in need — abundance is meant to circulate.',
    ],
    explainer:
        'Diwali — Deepavali, the row of lights — falls on the new moon of '
        'Kartika, the darkest night of the year. It marks the return of Rama '
        'to Ayodhya after 14 years of exile and the defeat of Ravana, the '
        'entire city lit with diyas to guide him home.\n\n'
        'It is also the night Lakshmi — goddess of abundance and grace — is '
        'said to visit homes that are clean, lit, and welcoming. Lakshmi does '
        'not enter homes of ego, darkness, or disorder — which is why Diwali '
        'traditionally begins weeks earlier with cleaning, repainting, and '
        'renewal.\n\n'
        'Each of the five days has its own significance: Dhanteras (wealth), '
        'Naraka Chaturdashi (cleansing), Diwali night (Lakshmi puja), '
        'Govardhan Puja (gratitude), and Bhai Dooj (sibling bonds). The '
        'entire arc moves from acquiring abundance to sharing it.',
  ),
  Festival(
    id: 'dev_deepawali',
    name: 'Dev Deepawali',
    sanskritName: 'देव दीपावली',
    date: DateTime(2026, 11, 24),
    shortDesc: 'Diwali of the gods — when the devas descend to the Ganga',
    deity: 'Shiva',
    emoji: '🌊',
    category: FestivalCategory.regional,
    howToObserve: const [
      'If in Varanasi, go to the ghats at dusk — the sight of hundreds of thousands of diyas on the Ganga is transformative.',
      'If not in Varanasi, light diyas on the bank of any river, lake, or body of water near you.',
      'Take a ritual bath (snan) in any sacred river — Kartik Purnima bathing washes away accumulated karma.',
      'Float a diya on a leaf in the water as an offering to the devas said to be present on this night.',
      'Recite the Shiva Tandava Stotram or Om Namah Shivaya 108 times in the evening.',
    ],
    explainer: 'Dev Deepawali — Diwali of the Gods — falls on the full moon of '
        'Kartika, fifteen days after Diwali. It is most magnificently '
        'celebrated in Varanasi, where the ghats of the Ganga are lit with '
        'hundreds of thousands of diyas.\n\n'
        'According to tradition, on this night all the devas descend from the '
        'heavens to bathe in the Ganga and celebrate the victory of Shiva over '
        'the demon Tripurasura. The celestial beings join humans on the river '
        'banks for one night.\n\n'
        'It is also Kartik Purnima — one of the most auspicious bathing days '
        'of the Hindu calendar. Bathing in any sacred river on this day is '
        'believed to wash away accumulated karma. The sight of Varanasi\'s '
        'ghats on this night — entirely ringed with fire — is considered one '
        'of the most beautiful sights in Bharat.',
  ),
];
