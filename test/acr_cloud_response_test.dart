import 'package:flutter_acrcloud/src/acrcloud_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ACRCloudResponse, () {
    test('parses music JSON metadata', () {
      final response = ACRCloudResponse.fromJson(_mockMusicFilesData);
      final data = response.metadata!.music.first;

      expect(data.label, 'XL Recording');
      expect(data.title, 'Hello');
      expect(data.acrId, '6049f11da7095e8bb8266871d4a70873');
      expect(data.durationMs, 295000);
      expect(data.score, 100);
      expect(data.playOffsetMs, 9040);
      expect(data.artists.first.name, 'Adele');
      expect(data.releaseDate, '2015-10-23');
      expect(data.album.name, 'Hello');
    });

    test('parses custom files JSON metadata', () {
      final response = ACRCloudResponse.fromJson(_mockCustomFilesData);
      final data = response.metadata!.customFiles.first;

      expect(data.title, 'You are beautiful');
      expect(data.acrId, '5343bc191634b042622bf474ed46121a');
      expect(data.durationMs, 852037);
      expect(data.score, 100);
      expect(data.playOffsetMs, 397791);
    });
  });
}

// Sample Metadata from https://docs.acrcloud.com/metadata/custom-files
const _mockCustomFilesData = {
  'status': {'msg': 'Success', 'code': 0, 'version': '1.0'},
  'metadata': {
    'timestamp_utc': '2015-07-27 12:56:46',
    'custom_files': [
      {
        'bucket_id': '51',
        'title': 'You are beautiful',
        'artist': 'James',
        'acrid': '5343bc191634b042622bf474ed46121a',
        'audio_id': '3',
        'duration_ms': 852037,
        'score': 100,
        'play_offset_ms': 397791
      }
    ]
  },
  'result_type': 0
};

// Sample Metadata from https://docs.acrcloud.com/metadata/music
const _mockMusicFilesData = {
  'metadata': {
    'timestamp_utc': '2020-01-19 02:58:28',
    'music': [
      {
        'db_begin_time_offset_ms': 0,
        'db_end_time_offset_ms': 9280,
        'sample_begin_time_offset_ms': 0,
        'sample_end_time_offset_ms': 9280,
        'play_offset_ms': 9040,
        'artists': [
          {
            'name': 'Adele',
            'langs': [
              {'code': 'zh-Hans', 'name': '阿黛尔'}
            ]
          }
        ],
        'acrid': '6049f11da7095e8bb8266871d4a70873',
        'album': {
          'name': 'Hello',
          'langs': [
            {'code': 'zh-Hans', 'name': 'Hello'}
          ]
        },
        'rights_claim': [
          {
            'distributor': {
              'id': 'PADPIDA2007050901U',
              'name': 'Warner Music Group'
            },
            'rights_owners': [
              {'name': 'Warner Music Group', 'share_percentage': 100.00}
            ],
            'rights_claim_policy': 'monetize',
            'territories': ['AD', 'AE', 'AF']
          },
          {
            'distributor': {
              'id': 'PADPIDA2007040502I',
              'name': 'Sony Music Entertainment'
            },
            'rights_owners': [
              {'name': 'Sony Music Entertainment', 'share_percentage': 100.00}
            ],
            'territories': ['AB', 'AC']
          }
        ],
        'external_ids': {
          'iswc': 'T9178198088',
          'isrc': 'GBBKS1500214',
          'upc': '886445581959'
        },
        'result_from': 3,
        'contributors': {
          'composers': ['Adele Adkins', 'Greg Kurstin'],
          'lyricists': ['ADELE ADKINS', 'GREGORY KURSTIN']
        },
        'title': 'Hello',
        'langs': [
          {'code': 'zh-Hans', 'name': 'Hello'}
        ],
        'language': 'en',
        'duration_ms': 295000,
        'label': 'XL Recording',
        'external_metadata': {
          'musicbrainz': {
            'track': {'id': '0a8e8d55-4b83-4f8a-9732-fbb5ded9f344'}
          },
          'deezer': {
            'track': {'id': '110265034'},
            'artists': [
              {'id': '75798'}
            ],
            'album': {'id': '11483764'}
          },
          'spotify': {
            'track': {'id': '4aebBr4JAihzJQR0CiIZJv'},
            'artists': [
              {'id': '4dpARuHxo51G3z768sgnrY'}
            ],
            'album': {'id': '7uwTHXmFa1Ebi5flqBosig'}
          },
          'musicstory': {
            'track': {'id': '13106540'},
            'album': {'id': '931271'}
          },
          'youtube': {'vid': 'YQHsXMglC9A'}
        },
        'score': 100,
        'genres': [
          {'name': 'Pop'}
        ],
        'release_date': '2015-10-23',
        'release_by_territories': [
          {
            'territories': ['DK'],
            'release_date': '2006-04-17'
          },
          {
            'territories': ['JP'],
            'release_date': '2006-10-17'
          },
          {
            'territories': ['SE'],
            'release_date': '2005-06-21'
          },
          {
            'exclude_territories': ['CN'],
            'territories': [
              'BG',
              'AL',
              'BA',
              'CZ',
              'EE',
              'HR',
              'HU',
              'LT',
              'LV',
              'MK',
              'ME',
              'PL',
              'RO',
              'RS',
              'SI',
              'SK',
              'UA'
            ],
            'release_date': '2006-03-24'
          },
          {
            'territories': ['GB', 'IE', 'NZ'],
            'release_date': '2005-07-18'
          },
          {
            'territories': ['FR'],
            'release_date': '2005-07-26'
          }
        ],
        'works': [
          {
            'iswc': 'T9178198088',
            'name': 'HELLO',
            'creators': [
              {'name': 'KURSTIN GREGORY ALLEN', 'ipi': 122619891},
              {'name': 'ADKINS ADELE LAURIE BLUE', 'ipi': 544476240},
            ]
          }
        ],
      },
    ],
  },
  'status': {'msg': 'Success', 'version': '1.0', 'code': 0},
  'result_type': 0
};
