//
//  ComicLanguage.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

enum ComicLanguage: String, CaseIterable {
    case english = "en"
    case french = "fr"
    case italian = "it"
    case spanish = "es"
    case brazilianPortuguese = "pt_BR"
    case polish = "pl"
    case latinSpanish = "es_CO"
    case german = "de"
    case catalan = "ct_CT"
    case portuguese = "pt"
    case japanese = "jp"
    case chinese = "cn"
    case hungarian = "hu_HU"
    case dutch = "nl"
    case korean = "kr_KR"
    case turkish = "tr_TR"
    case arabic = "ar_JO"
    case veneto = "xx_VE"
    case lombard = "xx_LMO"
    case greek = "gr_GR"
    case basque = "eu_EH"
    case swedish = "sv_SE"
    case hebrew = "he_HE"
    case galician = "ga_ES"
    case russian = "ru_RU"
    case corsican = "co_FR"
    case lithuanian = "lt_LT"
    case latin = "la_LA"
    case danish = "da_DK"
    case romanian = "ro_RO"
    case finnish = "fi_FI"
    case croatian = "hr_HR"
    case norwegian = "no_NO"
    case filipino = "tl_PI"
    case bulgarian = "bg_BG"
    case breton = "br_FR"
    case parodySalagir = "fr_PA"
}


// MARK: - DisplayName
extension ComicLanguage {
    var displayName: String {
        switch self {
        case .english: 
            return "English"
        case .french:
            return "Français"
        case .italian:
            return "Italiano"
        case .spanish:
            return "Español"
        case .brazilianPortuguese: 
            return "Português Brasileiro"
        case .polish:
            return "Polski"
        case .latinSpanish: 
            return "Español Latino"
        case .german:
            return "Deutsch"
        case .catalan: 
            return "Català"
        case .portuguese: 
            return "Português"
        case .japanese: 
            return "日本語"
        case .chinese: 
            return "中文"
        case .hungarian: 
            return "Magyar"
        case .dutch: 
            return "Nederlands"
        case .korean: 
            return "Korean"
        case .turkish: 
            return "Turc"
        case .arabic: 
            return "اللغة العربية"
        case .veneto: 
            return "Vèneto"
        case .lombard: 
            return "Lombard"
        case .greek: 
            return "Ελληνικά"
        case .basque: 
            return "Euskera"
        case .swedish: 
            return "Svenska"
        case .hebrew: 
            return "עִבְרִית"
        case .galician: 
            return "Galego"
        case .russian: 
            return "Русский"
        case .corsican: 
            return "Corsu"
        case .lithuanian: 
            return "Lietuviškai"
        case .latin: 
            return "Latine"
        case .danish: 
            return "Dansk"
        case .romanian: 
            return "România"
        case .finnish: 
            return "Suomeksi"
        case .croatian: 
            return "Croatian"
        case .norwegian: 
            return "Norsk"
        case .filipino: 
            return "Filipino"
        case .bulgarian: 
            return "Български"
        case .breton: 
            return "Brezhoneg"
        case .parodySalagir: 
            return "Parodie Salagir"
        }
    }
}
