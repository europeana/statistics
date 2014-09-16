class Data::Filz < ActiveRecord::Base

  #GEMS USED
  require 'csv'
  self.table_name = :data_filzs

  extend FriendlyId
  friendly_id :file_file_name, use: [:slugged]
  
  #ACCESSORS
  attr_accessible :content, :genre, :file_file_name, :core_oauth_id

  #ASSOCIATIONS
  belongs_to :core_oauth, class_name: "Core::Oauth", foreign_key: "core_oauth_id"
  has_many :viz_vizs, class_name: "Viz::Viz", foreign_key: "data_filz_id"

  #VALIDATIONS
  validate :file_file_name, presence: true, uniqueness: true, length: {minimum: 2}
  validates :content, length: {minimum: 5, message: "is too short (minimum is 5 rows)"}, allow_blank: true

  #CALLBACKS
  before_save :before_save_set
  after_update :after_update_set

  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS
  def self.getDataFromEuropeana    
    data_prodvier = "08614"
    provider_name = "EYE Film Institute"
    json_url = ['0AD2ECC9E62D3D2115D09B98045C36ACFE6518A8',
      '6A1C32C873D83844F924FB1CDC2F989268849D3B',
      '222583C32E370F026471D23D1FFA010785EF4B00', 
      'C2C160F96C03E63E986EF53E24231BE64E13C5A6',
      'FF33ECFF0032986144CFE25671CD91B88456A6C7',
      '47B42B946F50671BE222F9A100E50F6C43D00D65',
      '723E8D467110EFEEBFC62D17101A219FC26E8FEA',
      '91781EEF52CAF3AADFACE09E00AF4353BFFCD320',
      'FF33ECFF0032986144CFE25671CD91B88456A6C7',
      '06588F2BC6CBC66BCEE7F428E62B8426D2ED4984'
     ]
    year = 2011
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3a%22Rijksmuseum%22&rows=0"

    total_views = [7, 7, 3, 3, 3, 2, 2, 2, 2, 1 ]  

    uri = URI("http://europeana.eu/api//v2/record/#{data_prodvier}/#{jsurl}.json?wskey=api2demo&profile=full")
    total_obj = JSON.parse(Net::HTTP.get(uri))['totalResults']

    dump = []
    counter = 0 
    json_url.each do |jsurl|
      uri = URI("http://europeana.eu/api//v2/record/#{data_prodvier}/#{jsurl}.json?wskey=api2demo&profile=full")
      json = JSON.parse(Net::HTTP.get(uri))

      if json["object"]['proxies'][0]['dcTitle']["def"]
        title = json["object"]['proxies'][0]['dcTitle']["def"][0]
      elsif json["object"]['proxies'][0]['dcTitle']["fr"]
        title = json["object"]['proxies'][0]['dcTitle']["fr"][0]
      elsif json["object"]['proxies'][0]['dcTitle']["de"]
        title = json["object"]['proxies'][0]['dcTitle']["de"][0]
      end
      
      title_url = json["object"]['europeanaAggregation']['edmLandingPage']
      tot_views = total_views[counter]
      img_url = json["object"]['europeanaAggregation']['edmPreview']

      # tt = json["object"]['proxies'][0]['dcIdentifier']["def"][0]
      # title_url = "http://www.europeana.eu/portal/record/#{data_prodvier}/#{tt}.html" 

      if img_url.nil? 
        img_url = "http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO"
      end

      dump << {"year" => year, "provider"=> provider_name, "title" => title, "title_url" => title_url,
              "total_views" => tot_views, "img_url" => img_url, "total_object" => total_obj}
      
      counter += 1
    end    
    dump
  end

  def rij2014
    data_prodvier = 90402
    provider_name = "Rijksmuseum"
    json_url = ['collectie_RP_P_OB_51_507','collectie_SK_A_2885','collectie_SK_A_4',
      'collectie_RP_T_00_180', 'collectie_SK_A_1673', 'collectie_SK_A_2344',
      'collectie_SK_A_1892', 'collectie_RP_P_1956_733', 'collectie_RP_P_1894_A_18320',
      'collectie_SK_A_133']    
    total_views = [857,129,89,86,80,70,60,55,46,44]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3a%22Rijksmuseum%22&rows=0"
  end

  def rij2013
    data_prodvier = 90402
    provider_name = "Rijksmuseum"
    json_url = ['collectie_SK_A_1892','916B709DFD24C1197D25944C751F98F03A1E2A33','7E84EF66ED521A8882F8DEAD0D107618AF761BCB',
      '40CB9B9B39896B62170C82E113D062A383782A7F', 'collectie_RP_P_1958_434', '759D0AF3A698B4BE31FE18F07E60ED5DA6EF6D93',
      '74C1A612E91C3AFB74292050AB5BD3DF67DC6F1D', 'EBF530746A7000FD4AB979056C23CA1A34598587', 'AF88CC7C581335606C53F72FE0E6015D4D296B2A',
      'A541B0EAEADDF8A8CC32DA3B134BF32A55DFC733']
    year = 2013  

    total_views = [1105,879,486,475,322,203,196,156,154,148]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3a%22Rijksmuseum%22&rows=0"
    
  end

  def rij2012
    data_prodvier = 90402
    provider_name = "Rijksmuseum"
    json_url = ['7E84EF66ED521A8882F8DEAD0D107618AF761BCB','EBF530746A7000FD4AB979056C23CA1A34598587','40CB9B9B39896B62170C82E113D062A383782A7F',
      'CA5B6C8B575F57D0E509DD1EF5F5522D2D23814A', 'C2BA3869E8296C03B6ECAA5B28C280C93BEEEDF6', '49A7217431E5D5912CF39F42EBD3BC7E067D3B93',
      'EDFEE921FFF99AEF1819B900A3841D041AF2BAEB', 'AF88CC7C581335606C53F72FE0E6015D4D296B2A', '5FB7986F14BE449206CC69EFAEADD7AFA217FB97',
      '8EA374A6EFC4FB052C4DF500E13C8BE4F5E2FD24']
    year = 2012  

    total_views = [1103,375,194,115,107,86,72,61,60,59]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3a%22Rijksmuseum%22&rows=0"
    
  end

  def eye2012
    data_prodvier = "08614"
    provider_name = "EYE Film Institute"
    json_url = ['72C8DB5862C65D1A90EA70381B59F748FFE299AE','267599A0AD2F5B2EC482919F3769C2C4FD7CA5A9','3E9A397634BFE0BFB05DFD8FFB13928A82DBEE16',
      '8009AC36A75DDBDE48891DE339AC138D861819E2', '4F13F0C90B2AD0BBFCEFCDEA1376B8754440A76F', '6A1C32C873D83844F924FB1CDC2F989268849D3B',
      'B3AAA631D8AAC0D41D2BBB245E50A112B38F0EEF','B67E8AB67AAC4ADC07FD2B6B164505E12EA4B333','076B14F96174C054D954991CE08024B968B77166','38C33F79586568AA7961626FCF4EE96F14946F6C'
    ]
    year = 2012  

    total_views = [8,7,7,6,5,4,4,4,3,3]  

      if img_url.nil? and 1 == 2
        img_url = "http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO"
        tt = json["object"]['proxies'][0]['dcIdentifier']["def"][0]
        title_url = "http://www.europeana.eu/portal/record/#{data_prodvier}/#{tt}.html" 
      end

    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3A%22EYE+Film+Instituut+Nederland%22&rows=0"
  end

  def eye2013
    data_prodvier = "08614"
    provider_name = "EYE Film Institute"
    json_url = ['cat45818', '8009AC36A75DDBDE48891DE339AC138D861819E2', 'B32291CDDF6190FEFE0B93BBB930EBDA60CEDF69',
      'C2D2C4B0415E0949D3876213341C44393061EADA', 'D5B63F0906EC7DE3B019CE2CA084783F2D6E328D', '8F24B78F917251D9B74DCCC963F905FA1CA32DC0',
      '979D4481A85EBC4859634F2B707D5B006D1F2FAE', 'cat10125', '8009AC36A75DDBDE48891DE339AC138D861819E2', 'poster9960'
    ]
    year = 2013

    total_views = [9,13,6,6,6,5,5,5,4,4]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3A%22EYE+Film+Instituut+Nederland%22&rows=0"
  end

  def eye2014
    data_prodvier = "08614"
    provider_name = "EYE Film Institute"
    json_url = ['cat41703', 'poster2411', 'cat6923', 'poster5682', 'cat31131', 'cat34784', 'cat51754', 'cat19602', 'cat36456', 'cat33439']
    year = 2014
    total_views = [15,12,10,10,9,8,8,7,7,6]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER%3A%22EYE+Film+Instituut+Nederland%22&rows=0"
  end

  def fch2014
    data_prodvier = 92081
    provider_name = "French National Library"
    json_url = ['20CB9F2F302285108985CD4F4A0AF50E9E068ABD', 'FDB09C244698CDBE76067E49D2FC81E31655BB05', 'E9F82645747BEC673BA5A38662D4A4C2A4D388B6',
      '1E24078CAAD0D7CE555DACE0C4792548E5D5D437', 'E9F82645747BEC673BA5A38662D4A4C2A4D388B6', '9DF0BA93251C0F807483D4D514A84DB9D0751581',
      '1F3FB615C7A312FF97E59E7D94C01A3A6F09E644', '322542E17A59A52E50D59D31621F9EAA8BB840C5', '565DE04DC95D3171F1D7FFD2CEB8468FF1EF6E40', 'BCD9A2767C768FD5F6DF68E45DEC5B45B7695FCE'
    ]
    year = 2014

    total_views = [21,12,6,5,10,4,3,3,3,3]

    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER:%22National%20Library%20of%20France%22&rows=0"  

  end

  def fch2013
    data_prodvier = 92081
    provider_name = "French National Library"
    json_url = ['1E24078CAAD0D7CE555DACE0C4792548E5D5D437', '4A903C7B836966ADACEE9361EDC1A3171419C363', '9DF0BA93251C0F807483D4D514A84DB9D0751581',
      'E9F82645747BEC673BA5A38662D4A4C2A4D388B6', '257AEB597640D80049C006BA7AA04F107AE9965E', '3A594C06AFE682D21F77E2E46E9FB4DCBADFF27B', '41E9E1640E769EE04468D4909BC7C922445F455A', '463EB25AD9B9EE0BCB0D8B9524342B5931112EAB',
      'F05BF8FE0666E9F25A12947ADBFF22DA12875ABC', '11ADEC8B7435DF3BEE814B77CF0A98CBCA41A474'
    ]
    year = 2013
    total_views = [10,6,5,5,4,4,4,4,4,3]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER:%22National%20Library%20of%20France%22&rows=0"  
  end

  def fch2012
    data_prodvier = 92081
    provider_name = "French National Library"
    json_url = ['D89C97346865034B2D70A91F60D5D66ED2EC7410',
      '23CF9FF10C52056F797ED572815F42571402BB08',
      '64E5FA43793D4B22CA170748882B241C2107F361',
      '011217889B1550F5273CC72054BB4614692AE436',
      '18753F259C1EE46977A522944A15941AA2F6B040',
      '4533C3F8324830B9B591BF8D3B07E5D12A669086',
      '565DE04DC95D3171F1D7FFD2CEB8468FF1EF6E40',
      '1E24078CAAD0D7CE555DACE0C4792548E5D5D437',
      '82B5FB173E88270EDBBC8801387254EE30E742AA',
      '140EC680DF0D50DB3E0CF9E94966663F56E15CEB' ]
    year = 2012
    total_views = [19,10,9,8,8,7,7,6,6,5]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=DATA_PROVIDER:%22National%20Library%20of%20France%22&rows=0"  
    
  end

  def mio2012
    data_prodvier = "09102"
    provider_name = "Musical Instruments Online "
    json_url = ['498A6AFE1D619305B6814366558C8BF5C2A2E7D2',
      '21890C5DDEC72E268FEE283AC38A278E578914A5',
      'BAAFD27F63804E1C46D09036557AC75FE484A261',
      '09B72248FFAAC3DA88A11A037AFAF78286C86BAD',
      '3A0B49CA0CFEDA57A419B5815CFE433AB276E54E',
      '74F1BDE7D272E4A1D1105EC05C05A5E00A50D4D8',
      'F494B41DB09665CD411BCFDD4D537C543156E0C0',
      '30F71CDEC98EC804122C143C01A46543D19BC57B',
      '23900ED8070852C9E803DCB053C70E26C9B377ED',
      '81C6C124088D68679737AD5D6B9A7156B2C73CF1']
    year = 2012

    total_views = [4209, 993, 490,467, 382, 252, 194, 158, 145, 134]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22MIMO%20-%20Musical%20Instrument%20Museums%20Online%22&rows=0"
  end

  def mio2013
    data_prodvier = "09102"
    provider_name = "Musical Instruments Online "
    json_url = ['DC3D17297CDAA8B44C21CE0862905094DA04A72F',
     'D076F26DA9EBC707F1EE354B75FDAA57954E64E7',
     '1128A6C4A84CDC7E26DBF5E824824EB9EF56FE4F',
     '989979117989BB3D7BAE92ED81AD979C3704D587',
     '09B72248FFAAC3DA88A11A037AFAF78286C86BAD',
     '3A0B49CA0CFEDA57A419B5815CFE433AB276E54E',
     '21890C5DDEC72E268FEE283AC38A278E578914A5',
     '360185F933A7CD885D26FC7F8D38F9A11A5CBF14',
     '30F71CDEC98EC804122C143C01A46543D19BC57B',
     'AD22256B4BB51BC28320673CBB98854310B59279'

    ]
    year = 2013
    total_views = [311, 537, 184, 72, 126, 118, 90, 80, 78, 74 ]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22MIMO%20-%20Musical%20Instrument%20Museums%20Online%22&rows=0"
    
  end

  def mio2014
    data_prodvier = "09102"
    provider_name = "Musical Instruments Online "
    json_url = ['_ULEI_M0003234', '_CM_0130214', '_CM_0961918', '_spk_obj_257393',
      '_CM_0866640', '_CM_0866889', '_RMAH_110160_NL', '_ULEI_M0003134', '_ULEI_M0004303', '__AF_IT_DSMFI_STR0001_0000163']
    year = 2014
    total_views = [144, 67, 63, 43, 37, 37, 37, 37, 37, 36]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22MIMO%20-%20Musical%20Instrument%20Museums%20Online%22&rows=0"    
  end

  def dis2014
    data_prodvier = 2023601
    provider_name = "DISMARC"
    json_url = ['oai_eu_dismarc_CLAM_USA370978198',
      'oai_eu_dismarc_ORC_USA560303200',
      'oai_eu_dismarc_CHARM_DISC01SIDE02METSM629',
      'oai_eu_dismarc_GHT_001_000P397A1370',
      'oai_eu_dismarc_YLE_RADIO_ARCHIVES_MUSIC_RECORDINGS_000002136776',
      'oai_eu_dismarc_LLTI_00LTRFK34013',
      'oai_eu_dismarc_YLE_RADIO_ARCHIVES_SOUND_EFFECTS_ARCHIVE_000000001258',
      'oai_eu_dismarc_CVM_USA560830184',
      'oai_eu_dismarc_ISPAN_BRODA_00DVDT001222',
      'oai_eu_dismarc_ISPAN_00000T258012'
    ]
    year = 2014
    total_views = [117,65,58,38,38,30,30,28,27,26]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22DISMARC%20-%20EuropeanaConnect%22&rows=0"
  end

  def dis2013
    data_prodvier = 2023601
    provider_name = "DISMARC"
    json_url = ['oai_eu_dismarc_GHT_001_P10916A20947',
     'C37083D4CECA0388A7CD733A0B140C4CE0CFCB5A',
     '75E51308987AEC3457356FC9C43803A8BFEB63CA',
     '318F3CBC253EBE8A3EFBCBABE43FA9FB7880F34E',
     'oai_eu_dismarc_CLAM_USA370978198',
     '4E1CCC56703FA17FC0FFB942245ED410B915D088',
     '300FD6021EED879F0D35DCA90C23BB42A0B8BC08',
     '49621397B08DA6B40BB75CF07DA4FCCA600FDC93',
     '47A999A70EB5BEE520AAD9888FA4BF57F50EF379',
     '50A8E26B174D8EA2891CEAFBB48F4DBBDDBD2113'
    ]
    year = 2013
    total_views = [123,94,93,89,45,35,34,31,30,26]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22DISMARC%20-%20EuropeanaConnect%22&rows=0"
  end

  def mio2011
    data_prodvier = "09102"
    provider_name = "Musical Instruments Online"
    json_url = ['A2FCB3C52C64BE4CE976A55667ABA6C971BC4B30',
      'D0589DA05A06B7639C19A9D1FFD0DA391085832E',
      'B23BEE8F7153B71ED1649E25FF2AD55544180CCE',
      'F16DC9C552BF85898E211912B6A2FD1115D4EE38',
      '3A9673147DBD33719B1FF193E83E108DFBC94F46',
      '07891A1ABE96771139284AC5FDDE210D4EEF7958',
      '6D928220EF5C4D2D312A0E249C1B253AB91A158D',
      '092887556A6FC9A3E06D3999170F228D5D666638',
      '01E22BE925BDD6D13E06F3536FFF1C5D9AE22C7C',
      'B7BD966FD8BB70A3E60D08A5611C384A53479BC8'

     ]
    year = 2011
    total_views = [24,21,19,19,18,17,15,14,13,13]      
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22DISMARC%20-%20EuropeanaConnect%22&rows=0"
    
  end

  def fch2011
    data_prodvier = 92081
    provider_name = "French National Library"
    json_url = ['565DE04DC95D3171F1D7FFD2CEB8468FF1EF6E40',
      '18753F259C1EE46977A522944A15941AA2F6B040',
      '36E7BCC5D624E2BDCAE821E0513A60DC94FC86DB',
      'C876483A7CF9207D2D00C300FB72A09EF806E61A',
      'B182A06FFC8011279539760F57F74C37C1A0ACC8',
      '9B65A35DA2A2262A26E32EFF408471CFCCB0ABA3',
      '07D768CEFC488F4AA72DEE5691118686B7AF93EE',
      '41E9E1640E769EE04468D4909BC7C922445F455A',
      'C715DA5F07327E4D1E1B6A3AAD1AF3688977DF8E',
      '1AE19673FE4ABDBB19D440F0CA1B6E536EBCF9C5'
     ]
    year = 2011
    total_views = [125,59,32,29,27,25,21,16,13,12]  
    total_object_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=PROVIDER%3a%22DISMARC%20-%20EuropeanaConnect%22&rows=0"
    
  end

  def eye2011
    data_prodvier = "08614"
    provider_name = "EYE Film Institute"
    json_url = ['0AD2ECC9E62D3D2115D09B98045C36ACFE6518A8',
      '6A1C32C873D83844F924FB1CDC2F989268849D3B',
      '222583C32E370F026471D23D1FFA010785EF4B00', 
      'C2C160F96C03E63E986EF53E24231BE64E13C5A6',
      'FF33ECFF0032986144CFE25671CD91B88456A6C7',
      '47B42B946F50671BE222F9A100E50F6C43D00D65',
      '723E8D467110EFEEBFC62D17101A219FC26E8FEA',
      '91781EEF52CAF3AADFACE09E00AF4353BFFCD320',
      'FF33ECFF0032986144CFE25671CD91B88456A6C7',
      '06588F2BC6CBC66BCEE7F428E62B8426D2ED4984'
     ]
    year = 2011

    total_views = [7, 7, 3, 3, 3, 2, 2, 2, 2, 1 ]      
    
  end

  def self.ga_fetch_data
    data_prodviers = {
        :"9200105" => "Wellcome Library",
        :"90402" => "Rijksmuseum",
        :"92081" => "French National Library",
        :"920025" => "British Library"
        :"09102" => "MIMO",
        :"9200182" => "National Library of Wales",
        :"91909" => "Biblioteca de Catalunya",
        :"91910" => "Biblioteca de Catalunya",
        :"2020601" => "Europeana 1914-1918",
        :"20238" => "Linked Heritage",
        :"20220" => "HOPE",
        :"92039" => "National Library of Portugal",
        :"20261" => "Partage Plus",
        :"2026005" => "Macedonian Museum of Contemporary Art for Greece",
        :"11622" => "Naturkunde Museum Berlin",
        :"2022360" =>"Imperial War Museum",
        :"09209" => "Netherlands Institute for Sound and Vision", 
        :"2021601" => "Netherlands Institute for Sound and Vision",
        :"2022102" => "Netherlands Institute for Sound and Vision",
        :"2021610" => "Netherlands Institute for Sound and Vision"
    }

  #girish write code here  
    
  end
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_save_set    
    if self.content.present?
      con = self.content.class.to_s == "String" ? JSON.parse(self.content) : self.content
      con.delete_if{ |row| row.flatten.compact.empty? }
      new_header = Data::FilzColumn.get_headers(con)
      newa = []
      newa = [new_header.split(",")] + con
      con = newa
      self.content = con.to_json
    end
    true
  end
  
  def after_update_set
    self.viz_vizs.each do |viz|
      if viz.map.present?     
        raw_data = JSON.parse(self.content) 
        headings = raw_data.shift
        headings = headings.collect{|h| h.split(":").first}
        map_json = JSON.parse(viz.map).invert
        viz.mapped_output = viz.mapper(headings, map_json, raw_data)
        viz.save
      end
    end
    true
  end

end