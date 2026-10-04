import '../models/tourist_place.dart';

const List<TouristPlace> touristPlaces = [
  TouristPlace(
    name: 'Gateway of India',
    category: 'Historical',
    about:
        'The Gateway of India is one of Mumbai\'s most famous landmarks, located at Apollo Bunder near the Arabian Sea.',
    history:
        'The foundation stone was laid in 1911 and the monument was completed in 1924.',
    latitude: 18.9220,
    longitude: 72.8347,
    thingsToDo: [
      'Take photographs',
      'Enjoy the waterfront',
      'Visit nearby Colaba',
      'Take a ferry to Elephanta Caves',
    ],
    safetyTips: [
      'Keep valuables secure',
      'Be careful in crowded areas',
      'Follow ferry safety instructions',
    ],
    nearbyFood: [
      'Colaba restaurants',
      'Street food around Colaba',
      'Cafes near Apollo Bunder',
    ],
    visitingInfo:
        'Best visited during morning or evening. The area can become crowded during weekends and holidays.',
    planTips:
        'Combine Gateway of India with Colaba Causeway and nearby South Mumbai attractions.',
  ),

  TouristPlace(
    name: 'Marine Drive',
    category: 'Beach & Waterfront',
    about:
        'Marine Drive is a famous seafront boulevard along the Arabian Sea, popularly known as the Queen\'s Necklace.',
    history:
        'Marine Drive developed as part of Mumbai\'s major urban development and reclamation projects.',
    latitude: 18.9431,
    longitude: 72.8236,
    thingsToDo: [
      'Enjoy the sea view',
      'Watch the sunset',
      'Take photographs',
      'Walk along the promenade',
    ],
    safetyTips: [
      'Stay away from the sea edge during rough weather',
      'Avoid isolated areas late at night',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Girgaon restaurants',
      'Chowpatty food stalls',
      'South Mumbai cafes',
    ],
    visitingInfo:
        'The promenade is accessible throughout the day. Evening is a popular time to visit.',
    planTips:
        'Visit Marine Drive together with Girgaon Chowpatty and nearby South Mumbai attractions.',
  ),

  TouristPlace(
    name: 'CSMT',
    category: 'Heritage',
    about:
        'Chhatrapati Shivaji Maharaj Terminus is a historic railway terminus and one of Mumbai\'s most recognizable heritage buildings.',
    history:
        'The building was completed in 1888 and is an important example of Victorian Gothic architecture in India.',
    latitude: 18.9402,
    longitude: 72.8356,
    thingsToDo: [
      'See the historic architecture',
      'Take photographs',
      'Explore nearby heritage buildings',
      'Join a heritage walk',
    ],
    safetyTips: [
      'Be careful around railway areas',
      'Follow station rules',
      'Keep valuables secure',
    ],
    nearbyFood: [
      'Fort restaurants',
      'Cafes near CSMT',
      'Crawford Market food stalls',
    ],
    visitingInfo:
        'The station remains an active railway station, so visitors should follow railway regulations.',
    planTips:
        'Combine CSMT with Flora Fountain, Crawford Market and nearby Fort attractions.',
  ),

  TouristPlace(
    name: 'Elephanta Caves',
    category: 'Historical & UNESCO',
    about:
        'Elephanta Caves are a historic cave complex located on Elephanta Island in Mumbai Harbour.',
    history:
        'The main caves were constructed around the 5th to 6th centuries AD and contain important rock-cut sculptures.',
    latitude: 18.9633,
    longitude: 72.9315,
    thingsToDo: [
      'Explore the caves',
      'See ancient sculptures',
      'Enjoy the island surroundings',
      'Take photographs',
    ],
    safetyTips: [
      'Wear comfortable footwear',
      'Carry drinking water',
      'Follow site instructions',
      'Be careful on steps',
    ],
    nearbyFood: [
      'Food stalls near the ferry area',
      'Restaurants near Gateway of India',
    ],
    visitingInfo:
        'Ferries generally operate from Gateway of India. The caves are closed on Mondays.',
    planTips:
        'Keep several hours for the ferry journey and cave visit.',
  ),

  TouristPlace(
    name: 'Juhu Beach',
    category: 'Beach',
    about:
        'Juhu Beach is one of Mumbai\'s popular beaches and is known for its coastline, sunset views and street food.',
    history:
        'Juhu developed as an important residential and recreational area of Mumbai.',
    latitude: 19.0988,
    longitude: 72.8265,
    thingsToDo: [
      'Walk along the beach',
      'Watch the sunset',
      'Try local street food',
      'Take photographs',
    ],
    safetyTips: [
      'Avoid entering deep water',
      'Keep belongings secure',
      'Follow local beach warnings',
    ],
    nearbyFood: [
      'Juhu street food',
      'Juhu restaurants',
      'Cafes near Juhu',
    ],
    visitingInfo:
        'Evenings are popular because of the sunset and food stalls.',
    planTips:
        'Combine Juhu Beach with nearby Bandra and Santacruz attractions.',
  ),

  TouristPlace(
    name: 'Girgaon Chowpatty',
    category: 'Beach',
    about:
        'Girgaon Chowpatty is a popular Mumbai beach located near Marine Drive.',
    history:
        'The beach has long been associated with Mumbai\'s public celebrations and recreational life.',
    latitude: 18.9548,
    longitude: 72.8124,
    thingsToDo: [
      'Enjoy the beach',
      'Try local snacks',
      'Watch the sunset',
      'Take photographs',
    ],
    safetyTips: [
      'Avoid entering deep water',
      'Be careful in crowded areas',
      'Keep valuables secure',
    ],
    nearbyFood: [
      'Chowpatty food stalls',
      'Marine Drive restaurants',
    ],
    visitingInfo:
        'Evening is a popular time to visit.',
    planTips:
        'Visit after Marine Drive for a short evening itinerary.',
  ),

  TouristPlace(
    name: 'Bandra Bandstand',
    category: 'Waterfront',
    about:
        'Bandra Bandstand is a popular promenade overlooking the Arabian Sea.',
    history:
        'The Bandstand area became an important recreational and residential landmark in Bandra.',
    latitude: 19.0420,
    longitude: 72.8197,
    thingsToDo: [
      'Walk along the promenade',
      'Enjoy the sea view',
      'Take photographs',
      'Visit nearby Bandra attractions',
    ],
    safetyTips: [
      'Stay away from unsafe edges',
      'Avoid isolated areas late at night',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Bandra cafes',
      'Bandra restaurants',
      'Street food nearby',
    ],
    visitingInfo:
        'The promenade is especially popular during evenings.',
    planTips:
        'Combine Bandstand with Bandra Fort and Carter Road.',
  ),

  TouristPlace(
    name: 'Carter Road',
    category: 'Waterfront',
    about:
        'Carter Road is a popular seaside promenade in Bandra with walking paths, parks and restaurants.',
    history:
        'The promenade has developed into an important recreational area in western Mumbai.',
    latitude: 19.0633,
    longitude: 72.8207,
    thingsToDo: [
      'Walk along the promenade',
      'Enjoy the sea',
      'Visit nearby cafes',
      'Exercise outdoors',
    ],
    safetyTips: [
      'Keep valuables secure',
      'Follow pedestrian paths',
      'Avoid unsafe sea edges',
    ],
    nearbyFood: [
      'Bandra cafes',
      'Restaurants around Carter Road',
    ],
    visitingInfo:
        'Morning and evening are popular times for walking.',
    planTips:
        'Combine Carter Road with Bandstand and Bandra Fort.',
  ),

  TouristPlace(
    name: 'Worli Sea Face',
    category: 'Waterfront',
    about:
        'Worli Sea Face is a popular Mumbai waterfront offering views of the Arabian Sea and Bandra-Worli Sea Link.',
    history:
        'Worli is one of Mumbai\'s historic coastal settlements and has developed into a major urban area.',
    latitude: 19.0178,
    longitude: 72.8173,
    thingsToDo: [
      'Enjoy the sea view',
      'See the Sea Link',
      'Take photographs',
      'Walk along the promenade',
    ],
    safetyTips: [
      'Avoid unsafe sea edges',
      'Be cautious during rough weather',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Worli restaurants',
      'Lower Parel restaurants',
    ],
    visitingInfo:
        'Evening is a popular time for visiting.',
    planTips:
        'Combine Worli Sea Face with the Bandra-Worli Sea Link viewpoint.',
  ),

  TouristPlace(
    name: 'Haji Ali Dargah',
    category: 'Religious',
    about:
        'Haji Ali Dargah is a famous religious landmark located on an islet in the Arabian Sea.',
    history:
        'The shrine dates back to the 15th century and is associated with the Sufi saint Pir Haji Ali Shah Bukhari.',
    latitude: 18.9827,
    longitude: 72.8089,
    thingsToDo: [
      'Visit the shrine',
      'Observe the architecture',
      'Enjoy the sea surroundings',
    ],
    safetyTips: [
      'Dress respectfully',
      'Follow religious-site rules',
      'Be careful on the causeway during changing tides',
    ],
    nearbyFood: [
      'Mahalaxmi restaurants',
      'Worli food options',
    ],
    visitingInfo:
        'Access to the shrine depends on tide conditions.',
    planTips:
        'Check local conditions before planning the visit.',
  ),

  TouristPlace(
    name: 'Siddhivinayak Temple',
    category: 'Religious',
    about:
        'Siddhivinayak Temple is a famous Hindu temple dedicated to Lord Ganesha in Prabhadevi.',
    history:
        'The temple was established in 1801 and has become one of Mumbai\'s important religious destinations.',
    latitude: 19.0169,
    longitude: 72.8301,
    thingsToDo: [
      'Visit the temple',
      'Experience the religious atmosphere',
      'Learn about the temple history',
    ],
    safetyTips: [
      'Follow temple rules',
      'Keep valuables secure',
      'Expect crowds during festivals',
    ],
    nearbyFood: [
      'Prabhadevi restaurants',
      'Dadar food options',
    ],
    visitingInfo:
        'Temple timings and entry arrangements can vary.',
    planTips:
        'Check current temple timings before visiting.',
  ),

  TouristPlace(
    name: 'Sanjay Gandhi National Park',
    category: 'Nature',
    about:
        'Sanjay Gandhi National Park is a large protected green area within Mumbai.',
    history:
        'The park protects important natural habitats and contains several historic and archaeological features.',
    latitude: 19.2147,
    longitude: 72.9106,
    thingsToDo: [
      'Explore nature trails',
      'Enjoy the greenery',
      'Visit Kanheri Caves',
      'Observe wildlife',
    ],
    safetyTips: [
      'Follow park rules',
      'Do not feed wildlife',
      'Stay on designated paths',
      'Carry water',
    ],
    nearbyFood: [
      'Borivali restaurants',
      'Food options near the park entrance',
    ],
    visitingInfo:
        'Check park opening hours and activity availability before visiting.',
    planTips:
        'Reserve sufficient time because the park and Kanheri Caves require several hours.',
  ),

  TouristPlace(
    name: 'Kanheri Caves',
    category: 'Historical',
    about:
        'Kanheri Caves are a group of ancient rock-cut caves located inside Sanjay Gandhi National Park.',
    history:
        'The caves developed over many centuries and were an important Buddhist monastic centre.',
    latitude: 19.2056,
    longitude: 72.9061,
    thingsToDo: [
      'Explore the caves',
      'See ancient carvings',
      'Learn about Buddhist history',
      'Take photographs',
    ],
    safetyTips: [
      'Wear comfortable shoes',
      'Carry water',
      'Be careful on uneven surfaces',
    ],
    nearbyFood: [
      'Borivali restaurants',
      'Food options near the park',
    ],
    visitingInfo:
        'The caves are located inside Sanjay Gandhi National Park.',
    planTips:
        'Plan Kanheri Caves together with the national park visit.',
  ),

  TouristPlace(
    name: 'CSMVS',
    category: 'Museum',
    about:
        'Chhatrapati Shivaji Maharaj Vastu Sangrahalaya is a major museum in South Mumbai.',
    history:
        'The museum building was established in the early 20th century and houses collections of Indian art and history.',
    latitude: 18.9269,
    longitude: 72.8311,
    thingsToDo: [
      'Explore museum galleries',
      'View historical objects',
      'Learn about Indian art',
      'Attend exhibitions',
    ],
    safetyTips: [
      'Follow museum rules',
      'Do not touch exhibits',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Kala Ghoda restaurants',
      'Colaba cafes',
    ],
    visitingInfo:
        'Check museum opening hours and exhibition schedules before visiting.',
    planTips:
        'Combine with Gateway of India and Kala Ghoda attractions.',
  ),

  TouristPlace(
    name: 'Dr. Bhau Daji Lad Mumbai City Museum',
    category: 'Museum',
    about:
        'The Dr. Bhau Daji Lad Museum is Mumbai\'s oldest museum and focuses on the city\'s history and culture.',
    history:
        'The museum opened in 1872 and contains collections related to Mumbai\'s social and cultural history.',
    latitude: 18.9796,
    longitude: 72.8330,
    thingsToDo: [
      'Explore galleries',
      'See historical objects',
      'Learn about Mumbai history',
      'View exhibitions',
    ],
    safetyTips: [
      'Follow museum rules',
      'Do not touch displays',
    ],
    nearbyFood: [
      'Byculla restaurants',
      'Mazgaon food options',
    ],
    visitingInfo:
        'Check current museum timings before visiting.',
    planTips:
        'Combine with nearby Byculla attractions.',
  ),

  TouristPlace(
    name: 'Flora Fountain',
    category: 'Heritage',
    about:
        'Flora Fountain is a historic fountain located in the Fort area of South Mumbai.',
    history:
        'The fountain was constructed in 1869 and is named after Flora, the Roman goddess of flowers.',
    latitude: 18.9322,
    longitude: 72.8310,
    thingsToDo: [
      'See the heritage architecture',
      'Take photographs',
      'Explore Fort',
      'Join a heritage walk',
    ],
    safetyTips: [
      'Be careful while crossing roads',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Fort restaurants',
      'Kala Ghoda cafes',
    ],
    visitingInfo:
        'The fountain is located in a busy city area.',
    planTips:
        'Combine with CSMT, Rajabai Clock Tower and Fort heritage sites.',
  ),

  TouristPlace(
    name: 'Rajabai Clock Tower',
    category: 'Heritage',
    about:
        'Rajabai Clock Tower is a prominent Gothic Revival landmark located at the University of Mumbai.',
    history:
        'The tower was completed in 1878 and is named after Rajabai, the mother of businessman Premchand Roychand.',
    latitude: 18.9298,
    longitude: 72.8305,
    thingsToDo: [
      'View the architecture',
      'Take photographs',
      'Explore nearby Fort',
    ],
    safetyTips: [
      'Follow campus restrictions',
      'Be careful around traffic',
    ],
    nearbyFood: [
      'Fort cafes',
      'Kala Ghoda restaurants',
    ],
    visitingInfo:
        'Access to the tower interior may be restricted.',
    planTips:
        'Include it in a Fort heritage walk.',
  ),

  TouristPlace(
    name: 'Asiatic Society of Mumbai',
    category: 'Heritage',
    about:
        'The Asiatic Society of Mumbai is a historic institution and library located near Horniman Circle.',
    history:
        'The institution has a long history dating back to the early 19th century and houses important books and manuscripts.',
    latitude: 18.9322,
    longitude: 72.8370,
    thingsToDo: [
      'See the heritage building',
      'Explore the surrounding Fort area',
      'Take photographs',
    ],
    safetyTips: [
      'Follow visitor rules',
      'Keep valuables secure',
    ],
    nearbyFood: [
      'Fort restaurants',
      'Kala Ghoda cafes',
    ],
    visitingInfo:
        'Check visitor access and timings before planning an interior visit.',
    planTips:
        'Combine with Horniman Circle and other Fort heritage attractions.',
  ),

  TouristPlace(
    name: 'Colaba Causeway',
    category: 'Shopping',
    about:
        'Colaba Causeway is a popular shopping and street-market area in South Mumbai.',
    history:
        'The causeway developed as an important connection and commercial area in South Mumbai.',
    latitude: 18.9219,
    longitude: 72.8317,
    thingsToDo: [
      'Shop for souvenirs',
      'Explore street markets',
      'Visit nearby cafes',
      'Walk around Colaba',
    ],
    safetyTips: [
      'Watch your belongings',
      'Be careful in crowded areas',
      'Compare prices before purchasing',
    ],
    nearbyFood: [
      'Colaba cafes',
      'Restaurants along Causeway',
      'Street food',
    ],
    visitingInfo:
        'The area can become crowded, especially during weekends.',
    planTips:
        'Combine with Gateway of India and CSMVS.',
  ),

  TouristPlace(
    name: 'Mahatma Jyotiba Phule Mandai (Crawford Market)',
    category: 'Market',
    about:
        'Mahatma Jyotiba Phule Mandai, historically known as Crawford Market, is one of Mumbai\'s famous markets.',
    history:
        'The market building was completed in 1869 and is an important example of historic market architecture.',
    latitude: 18.9477,
    longitude: 72.8310,
    thingsToDo: [
      'Explore the market',
      'See historic architecture',
      'Shop for local products',
      'Experience Mumbai market culture',
    ],
    safetyTips: [
      'Keep valuables secure',
      'Be careful in crowded lanes',
      'Follow local market rules',
    ],
    nearbyFood: [
      'Market food stalls',
      'Fort restaurants',
      'Masjid Bunder food options',
    ],
    visitingInfo:
        'The market is a busy commercial area.',
    planTips:
        'Visit together with CSMT and South Mumbai heritage attractions.',
  ),

  TouristPlace(
    name: 'Mahalakshmi Temple',
    category: 'Religious',
    about:
        'Mahalakshmi Temple is a prominent Hindu temple located near the Arabian Sea.',
    history:
        'The temple is dedicated to Goddess Mahalakshmi and is an important religious site in Mumbai.',
    latitude: 18.9767,
    longitude: 72.8056,
    thingsToDo: [
      'Visit the temple',
      'Experience the surroundings',
      'Observe the architecture',
    ],
    safetyTips: [
      'Follow temple rules',
      'Dress respectfully',
      'Be careful in crowded areas',
    ],
    nearbyFood: [
      'Mahalakshmi restaurants',
      'Worli food options',
    ],
    visitingInfo:
        'Check current temple timings before visiting.',
    planTips:
        'Combine with Haji Ali and nearby coastal attractions.',
  ),

  TouristPlace(
    name: 'Mount Mary Basilica',
    category: 'Religious',
    about:
        'Mount Mary Basilica is a historic Roman Catholic basilica located in Bandra.',
    history:
        'The basilica is associated with the annual Bandra Fair and has a long religious history.',
    latitude: 19.0466,
    longitude: 72.8216,
    thingsToDo: [
      'Visit the basilica',
      'See the architecture',
      'Explore Bandra',
    ],
    safetyTips: [
      'Maintain religious-site etiquette',
      'Follow visitor instructions',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Bandra restaurants',
      'Bandra cafes',
    ],
    visitingInfo:
        'The area becomes especially busy during the annual Bandra Fair.',
    planTips:
        'Combine with Bandra Bandstand and Bandra Fort.',
  ),

  TouristPlace(
    name: 'Bandra Fort',
    category: 'Historical',
    about:
        'Bandra Fort is a historic fortification overlooking the Arabian Sea and Bandra-Worli Sea Link.',
    history:
        'The fort was built by the Portuguese in the 17th century.',
    latitude: 19.0421,
    longitude: 72.8194,
    thingsToDo: [
      'Explore the fort area',
      'Enjoy sea views',
      'Take photographs',
      'View the Sea Link',
    ],
    safetyTips: [
      'Be careful on uneven surfaces',
      'Avoid unsafe edges',
      'Visit during daylight or busy hours',
    ],
    nearbyFood: [
      'Bandra cafes',
      'Bandra restaurants',
    ],
    visitingInfo:
        'The fort area is popular for views of the sea and Sea Link.',
    planTips:
        'Combine with Bandstand and Mount Mary Basilica.',
  ),

  TouristPlace(
    name: 'Bandra-Worli Sea Link Viewpoint',
    category: 'Landmark',
    about:
        'The Bandra-Worli Sea Link is one of Mumbai\'s major infrastructure landmarks connecting Bandra and Worli.',
    history:
        'The cable-stayed bridge was opened to traffic in 2009.',
    latitude: 19.0355,
    longitude: 72.8197,
    thingsToDo: [
      'View the Sea Link',
      'Take photographs from permitted areas',
      'Enjoy the coastal scenery',
    ],
    safetyTips: [
      'Do not stop on restricted roads',
      'Use designated viewpoints',
      'Follow traffic rules',
    ],
    nearbyFood: [
      'Bandra restaurants',
      'Worli restaurants',
    ],
    visitingInfo:
        'The bridge itself is a road infrastructure facility; photography should be done from permitted locations.',
    planTips:
        'Use Bandra Fort or Worli Sea Face for views of the Sea Link.',
  ),

  TouristPlace(
    name: 'Global Vipassana Pagoda',
    category: 'Meditation & Architecture',
    about:
        'Global Vipassana Pagoda is a large meditation centre and architectural landmark near Gorai.',
    history:
        'The pagoda was built as a centre for Vipassana meditation and teaching.',
    latitude: 19.2288,
    longitude: 72.8053,
    thingsToDo: [
      'Explore the pagoda',
      'Learn about Vipassana',
      'Enjoy the peaceful surroundings',
      'See the architecture',
    ],
    safetyTips: [
      'Maintain silence where required',
      'Follow centre rules',
      'Dress appropriately',
    ],
    nearbyFood: [
      'Gorai restaurants',
      'Food options near the entrance',
    ],
    visitingInfo:
        'Check current visiting hours and entry rules before travelling.',
    planTips:
        'Combine with Gorai Beach if time permits.',
  ),

  TouristPlace(
    name: 'Aksa Beach',
    category: 'Beach',
    about:
        'Aksa Beach is a popular beach in Malad, known for its coastal scenery and relatively quieter surroundings.',
    history:
        'Aksa is part of Mumbai\'s western coastal area and has developed as a recreational destination.',
    latitude: 19.1759,
    longitude: 72.7954,
    thingsToDo: [
      'Enjoy the beach',
      'Watch the sunset',
      'Take photographs',
      'Walk along the shore',
    ],
    safetyTips: [
      'Do not enter deep water',
      'Follow local warnings',
      'Be careful during monsoon and rough sea conditions',
    ],
    nearbyFood: [
      'Malad restaurants',
      'Local food stalls',
    ],
    visitingInfo:
        'Check local beach conditions before entering the water.',
    planTips:
        'Visit during daylight and combine with nearby western Mumbai attractions.',
  ),

  TouristPlace(
    name: 'Gorai Beach',
    category: 'Beach',
    about:
        'Gorai Beach is a coastal destination in northwestern Mumbai near Gorai village.',
    history:
        'Gorai developed as a coastal village and recreational destination.',
    latitude: 19.2005,
    longitude: 72.7828,
    thingsToDo: [
      'Enjoy the beach',
      'Watch the sunset',
      'Take photographs',
      'Relax near the coast',
    ],
    safetyTips: [
      'Avoid deep water',
      'Check local warnings',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Gorai local restaurants',
      'Beachside food options',
    ],
    visitingInfo:
        'Travel time can vary depending on traffic and transport.',
    planTips:
        'Combine with Global Vipassana Pagoda.',
  ),

  TouristPlace(
    name: 'Powai Lake',
    category: 'Nature',
    about:
        'Powai Lake is an artificial lake in northern Mumbai surrounded by an urban and natural landscape.',
    history:
        'The lake was created in the 18th century as part of Mumbai\'s water infrastructure.',
    latitude: 19.1300,
    longitude: 72.9060,
    thingsToDo: [
      'Enjoy lake views',
      'Take photographs',
      'Walk around permitted areas',
      'Observe birds',
    ],
    safetyTips: [
      'Stay in designated areas',
      'Avoid entering the water',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Powai restaurants',
      'Hiranandani cafes',
    ],
    visitingInfo:
        'Access around the lake varies by location.',
    planTips:
        'Combine with other Powai attractions.',
  ),

  TouristPlace(
    name: 'Hanging Gardens',
    category: 'Garden',
    about:
        'Hanging Gardens is a terraced garden located on the western side of Malabar Hill.',
    history:
        'The garden was developed in the late 19th century and is associated with Mumbai\'s historic water infrastructure.',
    latitude: 18.9567,
    longitude: 72.8050,
    thingsToDo: [
      'Walk through the garden',
      'Enjoy city views',
      'Take photographs',
      'Relax in the greenery',
    ],
    safetyTips: [
      'Stay on designated paths',
      'Watch children around edges',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Malabar Hill restaurants',
      'Girgaon food options',
    ],
    visitingInfo:
        'Morning and evening are comfortable times for a visit.',
    planTips:
        'Combine with Kamala Nehru Park and Marine Drive.',
  ),

  TouristPlace(
    name: 'Kamala Nehru Park',
    category: 'Garden',
    about:
        'Kamala Nehru Park is a hilltop garden on Malabar Hill offering views of Marine Drive.',
    history:
        'The park is named after Kamala Nehru and has long been a recreational space in South Mumbai.',
    latitude: 18.9558,
    longitude: 72.8055,
    thingsToDo: [
      'Enjoy the city view',
      'Relax in the garden',
      'Take photographs',
      'Visit the famous shoe-shaped structure',
    ],
    safetyTips: [
      'Stay on designated paths',
      'Keep children supervised',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Malabar Hill restaurants',
      'Girgaon food options',
    ],
    visitingInfo:
        'The park is popular for views over Marine Drive.',
    planTips:
        'Combine with Hanging Gardens.',
  ),

  TouristPlace(
    name: 'Nehru Planetarium Mumbai',
    category: 'Science & Education',
    about:
        'Nehru Planetarium is an educational centre focused on astronomy and space science.',
    history:
        'The planetarium was established in 1977 as part of the Nehru Centre complex.',
    latitude: 18.9887,
    longitude: 72.8173,
    thingsToDo: [
      'Watch astronomy shows',
      'Learn about space',
      'Explore educational exhibits',
      'Attend special programs',
    ],
    safetyTips: [
      'Follow venue rules',
      'Keep children supervised',
    ],
    nearbyFood: [
      'Worli restaurants',
      'Lower Parel restaurants',
    ],
    visitingInfo:
        'Check show timings and ticket availability before visiting.',
    planTips:
        'Plan the visit around a scheduled planetarium show.',
  ),

  TouristPlace(
    name: 'Taraporewala Aquarium',
    category: 'Aquarium',
    about:
        'Taraporewala Aquarium is a historic public aquarium in Mumbai.',
    history:
        'The aquarium opened in 1951 and displays a variety of aquatic life.',
    latitude: 18.9440,
    longitude: 72.8240,
    thingsToDo: [
      'See aquatic exhibits',
      'Learn about marine life',
      'Take photographs where permitted',
    ],
    safetyTips: [
      'Follow aquarium rules',
      'Do not touch exhibits',
      'Supervise children',
    ],
    nearbyFood: [
      'Marine Drive restaurants',
      'Girgaon food stalls',
    ],
    visitingInfo:
        'Check current opening hours before visiting.',
    planTips:
        'Combine with Marine Drive and Girgaon Chowpatty.',
  ),

  TouristPlace(
    name: 'Madh Island',
    category: 'Coastal',
    about:
        'Madh Island is a coastal area in western Mumbai known for beaches, fishing villages and coastal scenery.',
    history:
        'Madh developed historically as a fishing and coastal settlement.',
    latitude: 19.1300,
    longitude: 72.7950,
    thingsToDo: [
      'Explore coastal areas',
      'Enjoy beach views',
      'Take photographs',
      'Experience the local atmosphere',
    ],
    safetyTips: [
      'Follow local beach warnings',
      'Avoid entering unsafe waters',
      'Keep valuables secure',
    ],
    nearbyFood: [
      'Madh Island restaurants',
      'Malad food options',
    ],
    visitingInfo:
        'Travel time can depend heavily on local traffic.',
    planTips:
        'Plan the trip during daylight.',
  ),

  TouristPlace(
    name: 'Versova Beach',
    category: 'Beach',
    about:
        'Versova Beach is a western Mumbai beach known for its coastline and community-led environmental efforts.',
    history:
        'Versova has traditionally been associated with fishing communities and Mumbai\'s western coastline.',
    latitude: 19.1350,
    longitude: 72.8150,
    thingsToDo: [
      'Walk along the beach',
      'Watch the sunset',
      'Take photographs',
      'Learn about beach-cleaning initiatives',
    ],
    safetyTips: [
      'Avoid entering deep water',
      'Follow local warnings',
      'Keep belongings secure',
    ],
    nearbyFood: [
      'Versova restaurants',
      'Andheri cafes',
    ],
    visitingInfo:
        'Check local conditions before planning beach activities.',
    planTips:
        'Combine with nearby Andheri and western Mumbai attractions.',
  ),

  TouristPlace(
    name: 'Khotachiwadi',
    category: 'Heritage Village',
    about:
        'Khotachiwadi is a historic heritage precinct in Girgaon known for its traditional houses and lanes.',
    history:
        'The area preserves an older architectural character associated with Mumbai\'s urban heritage.',
    latitude: 18.9544,
    longitude: 72.8230,
    thingsToDo: [
      'Explore heritage lanes',
      'See traditional houses',
      'Take photographs respectfully',
      'Learn about local heritage',
    ],
    safetyTips: [
      'Respect residents\' privacy',
      'Avoid blocking narrow lanes',
      'Keep noise low',
    ],
    nearbyFood: [
      'Girgaon restaurants',
      'Chowpatty food stalls',
    ],
    visitingInfo:
        'Khotachiwadi is a residential heritage area, so visitors should behave respectfully.',
    planTips:
        'Combine with Girgaon Chowpatty and Marine Drive.',
  ),

  TouristPlace(
    name: 'Banganga Tank',
    category: 'Heritage & Religious',
    about:
        'Banganga Tank is an ancient water tank located in Walkeshwar, Malabar Hill.',
    history:
        'The site is associated with the Walkeshwar temple complex and has a long religious history.',
    latitude: 18.9492,
    longitude: 72.8055,
    thingsToDo: [
      'Explore the historic site',
      'See the temple surroundings',
      'Learn about local history',
      'Take photographs respectfully',
    ],
    safetyTips: [
      'Respect religious customs',
      'Keep the area clean',
      'Avoid disturbing worshippers',
    ],
    nearbyFood: [
      'Malabar Hill restaurants',
      'Walkeshwar food options',
    ],
    visitingInfo:
        'This is an active religious and residential area.',
    planTips:
        'Combine with Walkeshwar Temple and Hanging Gardens.',
  ),

  TouristPlace(
    name: 'Walkeshwar Temple',
    category: 'Religious',
    about:
        'Walkeshwar Temple is a historic Hindu temple in the Malabar Hill area.',
    history:
        'The temple is traditionally associated with the Walkeshwar area and its ancient religious traditions.',
    latitude: 18.9480,
    longitude: 72.8060,
    thingsToDo: [
      'Visit the temple',
      'Observe the architecture',
      'Explore nearby Banganga',
    ],
    safetyTips: [
      'Follow temple rules',
      'Dress respectfully',
      'Keep noise low',
    ],
    nearbyFood: [
      'Malabar Hill restaurants',
      'South Mumbai food options',
    ],
    visitingInfo:
        'Check current temple timings before visiting.',
    planTips:
        'Combine with Banganga Tank and Hanging Gardens.',
  ),

  TouristPlace(
    name: 'Mani Bhavan Gandhi Sangrahalaya',
    category: 'History & Museum',
    about:
        'Mani Bhavan Gandhi Sangrahalaya is a museum and memorial associated with Mahatma Gandhi\'s activities in Mumbai.',
    history:
        'Mani Bhavan served as Gandhi\'s base in Mumbai during important periods of the Indian freedom movement.',
    latitude: 18.9622,
    longitude: 72.8110,
    thingsToDo: [
      'Explore the museum',
      'See historical exhibits',
      'Learn about Gandhi\'s life',
      'View the memorial rooms',
    ],
    safetyTips: [
      'Follow museum rules',
      'Do not touch exhibits',
    ],
    nearbyFood: [
      'Gamdevi restaurants',
      'Girgaon food options',
    ],
    visitingInfo:
        'Check museum timings before visiting.',
    planTips:
        'Combine with nearby South Mumbai heritage attractions.',
  ),

  TouristPlace(
    name: 'Maharashtra Nature Park',
    category: 'Nature',
    about:
        'Maharashtra Nature Park is an urban green space in Dharavi with plants, birds and walking areas.',
    history:
        'The park was developed on a former garbage dumping ground and transformed into a green space.',
    latitude: 19.0430,
    longitude: 72.8560,
    thingsToDo: [
      'Explore the greenery',
      'Observe birds',
      'Walk through nature areas',
      'Learn about the environment',
    ],
    safetyTips: [
      'Stay on designated paths',
      'Do not disturb wildlife',
      'Follow park rules',
    ],
    nearbyFood: [
      'Sion restaurants',
      'Dharavi food options',
    ],
    visitingInfo:
        'Check park timings and visitor rules before visiting.',
    planTips:
        'A good option for a short nature-focused visit within the city.',
  ),

  TouristPlace(
    name: 'Sewri Fort',
    category: 'Historical',
    about:
        'Sewri Fort is a historic fortification located near the eastern waterfront of Mumbai.',
    history:
        'The fort was built by the British in the 17th century as part of Mumbai\'s defensive network.',
    latitude: 18.9680,
    longitude: 72.8560,
    thingsToDo: [
      'Explore the historic area',
      'Take photographs',
      'Learn about Mumbai\'s defensive history',
    ],
    safetyTips: [
      'Be careful on uneven surfaces',
      'Follow access restrictions',
      'Visit during daylight',
    ],
    nearbyFood: [
      'Sewri restaurants',
      'Wadala food options',
    ],
    visitingInfo:
        'Access conditions can vary, so check locally before visiting.',
    planTips:
        'Combine with Sewri Mudflats during the appropriate season.',
  ),

  TouristPlace(
    name: 'Sewri Mudflats',
    category: 'Nature & Birdwatching',
    about:
        'Sewri Mudflats are an important coastal wetland area known for migratory birds.',
    history:
        'The mudflats form part of Mumbai\'s eastern coastal ecosystem.',
    latitude: 18.9710,
    longitude: 72.8580,
    thingsToDo: [
      'Birdwatching',
      'Observe coastal wildlife',
      'Take nature photographs',
    ],
    safetyTips: [
      'Stay away from unsafe tidal areas',
      'Do not disturb birds',
      'Follow local access rules',
    ],
    nearbyFood: [
      'Sewri food options',
      'Wadala restaurants',
    ],
    visitingInfo:
        'Bird activity varies by season and tide.',
    planTips:
        'Plan the visit according to birding season and daylight hours.',
  ),

  TouristPlace(
    name: 'Nehru Science Centre',
    category: 'Science & Education',
    about:
        'Nehru Science Centre is a major science education centre with interactive exhibits in Mumbai.',
    history:
        'The centre was developed as part of India\'s science education and public outreach efforts.',
    latitude: 18.9907,
    longitude: 72.8174,
    thingsToDo: [
      'Explore interactive exhibits',
      'Learn about science',
      'Visit educational displays',
      'Attend special programs',
    ],
    safetyTips: [
      'Follow centre rules',
      'Supervise children',
      'Do not damage exhibits',
    ],
    nearbyFood: [
      'Worli restaurants',
      'Lower Parel food options',
    ],
    visitingInfo:
        'Check opening hours and special exhibition schedules.',
    planTips:
        'Combine with Nehru Planetarium if timings permit.',
  ),

  TouristPlace(
    name: 'Mumbai Film City (Dadasaheb Phalke Chitranagari)',
    category: 'Entertainment',
    about:
        'Mumbai Film City is a major film and television production complex located in Goregaon.',
    history:
        'The complex was established in 1977 and is associated with Mumbai\'s film and television industry.',
    latitude: 19.1635,
    longitude: 72.8950,
    thingsToDo: [
      'Explore permitted film locations',
      'Learn about film production',
      'Take photographs where allowed',
    ],
    safetyTips: [
      'Follow entry and security rules',
      'Do not enter restricted production areas',
      'Carry valid identification if required',
    ],
    nearbyFood: [
      'Goregaon restaurants',
      'Aarey food options',
    ],
    visitingInfo:
        'Entry may require a permitted tour or authorization.',
    planTips:
        'Check official tour availability before planning the visit.',
  ),

  TouristPlace(
    name: 'Aarey Forest',
    category: 'Nature',
    about:
        'Aarey is a large green area in northern Mumbai with forested landscapes and biodiversity.',
    history:
        'Aarey developed as a planned green and dairy area and contains important urban ecological spaces.',
    latitude: 19.1450,
    longitude: 72.8790,
    thingsToDo: [
      'Explore nature areas',
      'Observe plants and birds',
      'Take nature photographs',
      'Enjoy a peaceful environment',
    ],
    safetyTips: [
      'Stay on known paths',
      'Avoid isolated areas',
      'Do not disturb wildlife',
      'Follow local restrictions',
    ],
    nearbyFood: [
      'Goregaon restaurants',
      'Powai food options',
    ],
    visitingInfo:
        'Access and permitted areas can vary.',
    planTips:
        'Visit during daylight and follow local access rules.',
  ),

  TouristPlace(
    name: 'Versova Fort',
    category: 'Historical',
    about:
        'Versova Fort is a historic fortification located near the western coast of Mumbai.',
    history:
        'The fort is associated with the Portuguese and later British periods of Mumbai\'s coastal history.',
    latitude: 19.1260,
    longitude: 72.8130,
    thingsToDo: [
      'Explore the fort area',
      'Learn about local history',
      'Take photographs',
      'Enjoy coastal views',
    ],
    safetyTips: [
      'Be careful on uneven surfaces',
      'Follow access restrictions',
      'Visit during daylight',
    ],
    nearbyFood: [
      'Versova restaurants',
      'Andheri cafes',
    ],
    visitingInfo:
        'Access conditions can vary, so check locally before visiting.',
    planTips:
        'Combine with Versova Beach and nearby western Mumbai attractions.',
  ),
];