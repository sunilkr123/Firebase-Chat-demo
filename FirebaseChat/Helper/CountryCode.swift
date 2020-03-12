//
//  CountryCode.swift
//  iChat
//
//  Created by David Kababyan on 01/07/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import CoreTelephony

class CountryCode {
    
    var currentCode: String!
    var allCodes: [String]!
    
    let codeDictionaryShort = ["BD": "+880", "BE": "+32", "BF": "+226", "BG": "+359", "BA": "+387", "BB": "+1-246", "WF": "+681", "BL": "+590", "BM": "+1-441", "BN": "+673", "BO": "+591", "BH": "+973", "BI": "+257", "BJ": "+229", "BT": "+975", "JM": "+1-876", "BV": "", "BW": "+267", "WS": "+685", "BQ": "+599", "BR": "+55", "BS": "+1-242", "JE": "+44-1534", "BY": "+375", "BZ": "+501", "RU": "+7", "RW": "+250", "RS": "+381", "TL": "+670", "RE": "+262", "TM": "+993", "TJ": "+992", "RO": "+40", "TK": "+690", "GW": "+245", "GU": "+1-671", "GT": "+502", "GS": "", "GR": "+30", "GQ": "+240", "GP": "+590", "JP": "+81", "GY": "+592", "GG": "+44-1481", "GF": "+594", "GE": "+995", "GD": "+1-473", "GB": "+44", "GA": "+241", "SV": "+503", "GN": "+224", "GM": "+220", "GL": "+299", "GI": "+350", "GH": "+233", "OM": "+968", "TN": "+216", "JO": "+962", "HR": "+385", "HT": "+509", "HU": "+36", "HK": "+852", "HN": "+504", "HM": "", "VE": "+58", "PR": "+1-787", "PS": "+970", "PW": "+680", "PT": "+351", "SJ": "+47", "PY": "+595", "IQ": "+964", "PA": "+507", "PF": "+689", "PG": "+675", "PE": "+51", "PK": "+92", "PH": "+63", "PN": "+870", "PL": "+48", "PM": "+508", "ZM": "+260", "EH": "+212", "EE": "+372", "EG": "+20", "ZA": "+27", "EC": "+593", "IT": "+39", "VN": "+84", "SB": "+677", "ET": "+251", "SO": "+252", "ZW": "+263", "SA": "+966", "ES": "+34", "ER": "+291", "ME": "+382", "MD": "+373", "MG": "+261", "MF": "+590", "MA": "+212", "MC": "+377", "UZ": "+998", "MM": "+95", "ML": "+223", "MO": "+853", "MN": "+976", "MH": "+692", "MK": "+389", "MU": "+230", "MT": "+356", "MW": "+265", "MV": "+960", "MQ": "+596", "MP": "+1-670", "MS": "+1-664", "MR": "+222", "IM": "+44-1624", "UG": "+256", "TZ": "+255", "MY": "+60", "MX": "+52", "IL": "+972", "FR": "+33", "IO": "+246", "SH": "+290", "FI": "+358", "FJ": "+679", "FK": "+500", "FM": "+691", "FO": "+298", "NI": "+505", "NL": "+31", "NO": "+47", "NA": "+264", "VU": "+678", "NC": "+687", "NE": "+227", "NF": "+672", "NG": "+234", "NZ": "+64", "NP": "+977", "NR": "674+", "NU": "+683", "CK": "+682", "XK": "", "CI": "+225", "CH": "+41", "CO": "+57", "CN": "+86", "CM": "+237", "CL": "+56", "CC": "+61", "CA": "+1", "CG": "+242", "CF": "+236", "CD": "+243", "CZ": "+420", "CY": "+357", "CX": "+61", "CR": "+506", "CW": "+599", "CV": "+238", "CU": "+53", "SZ": "+268", "SY": "+963", "SX": "+599", "KG": "+996", "KE": "+254", "SS": "+211", "SR": "+597", "KI": "+686", "KH": "+855", "KN": "+1-869", "KM": "+269", "ST": "+239", "SK": "+421", "KR": "+82", "SI": "+386", "KP": "+850", "KW": "+965", "SN": "+221", "SM": "+378", "SL": "+232", "SC": "+248", "KZ": "+7", "KY": "+1-345", "SG": "+65", "SE": "+46", "SD": "+249", "DO": "+1-809", "DM": "+1-767", "DJ": "+253", "DK": "+45", "VG": "+1-284", "DE": "+49", "YE": "+967", "DZ": "+213", "US": "+1", "UY": "+598", "YT": "+262", "UM": "+1", "LB": "+961", "+LC": "+1-758", "LA": "+856", "TV": "+688", "TW": "+886", "TT": "+1-868", "TR": "+90", "LK": "+94", "LI": "+423", "LV": "+371", "TO": "+676", "LT": "+370", "LU": "+352", "LR": "+231", "LS": "+266", "TH": "+66", "TF": "", "TG": "+228", "TD": "+235", "TC": "+1-649", "LY": "+218", "VA": "+379", "VC": "+1-784", "AE": "+971", "AD": "+376", "AG": "+1-268", "AF": "+93", "AI": "+1-264", "VI": "+1-340", "IS": "+354", "IR": "+98", "AM": "+374", "AL": "+355", "AO": "+244", "AQ": "", "AS": "+1-684", "AR": "+54", "AU": "+61", "AT": "+43", "AW": "+297", "IN": "+91", "AX": "+358-18", "AZ": "+994", "IE": "+353", "ID": "+62", "UA": "+380", "QA": "+974", "MZ": "+258"]
    
    
    let codeDictionary = ["Belarus ":"+375", "Singapore ":"+65", "Tajikistan ":"+992", "Barbados ":"+1-246", "Eritrea ":"+291", "Isle of Man ":"+44-1624", "Lesotho ":"+266", "Indonesia ":"+62", "Palau ":"+680", "Saint Martin ":"+590", "Sint Maarten ":"+599", "Myanmar ":"+95", "Mozambique ":"+258", "Bosnia and Herzegovina ":"+387", "Brazil ":"+55", "Cameroon ":"+237", "East Timor ":"+670", "Madagascar ":"+261", "Austria ":"+43", "Marshall Islands ":"+692", "Argentina ":"+54", "Nepal ":"+977", "Kiribati ":"+686", "Norway ":"+47", "Macao ":"+853", "Solomon Islands ":"+677", "United States Minor Outlying Islands ":"+1", "Seychelles ":"+248", "Uzbekistan ":"+998", "Cayman Islands ":"+1-345", "Suriname ":"+597", "North Korea ":"+850", "Mauritius ":"+230", "Mongolia ":"+976", "Libya ":"+218", "Antigua and Barbuda ":"+1-268", "Anguilla ":"+1-264", "Italy ":"+39", "Sierra Leone ":"+232", "Turkmenistan ":"+993", "Guernsey ":"+44-1481", "French Guiana ":"+594", "Senegal ":"+221", "Laos ":"+856", "Honduras ":"+504", "Andorra ":"+376", "Uganda ":"+256", "Slovakia ":"+421", "Ukraine ":"+380", "Bermuda ":"+1-441", "Slovenia ":"+386", "Switzerland ":"+41", "Aland Islands ":"+358-18", "Dominican Republic ":"+1-809", "Guinea-Bissau ":"+245", "Serbia ":"+381", "Vanuatu ":"+678", "Turks and Caicos Islands ":"+1-649", "Latvia ":"+371", "Ireland ":"+353", "Republic of the Congo ":"+242", "Djibouti ":"+253", "Guyana ":"+592", "Philippines ":"+63", "Gambia ":"+220", "Spain ":"+34", "Niue ":"+683", "Northern Mariana Islands ":"+1-670", "Benin ":"+229", "Greece ":"+30", "Colombia ":"+57", "Canada ":"+1", "Saint Pierre and Miquelon ":"+508", "Sudan ":"+249", "Croatia ":"+385", "Central African Republic ":"+236", "Morocco ":"+212", "Norfolk Island ":"+672", "Curacao ":"+599", "Macedonia ":"+389", "Dominica ":"+1-767", "Portugal ":"+351", "Turkey ":"+90", "El Salvador ":"+503", "Trinidad and Tobago ":"+1-868", "Brunei ":"+673", "Guatemala ":"+502", "Liechtenstein ":"+423", "Sao Tome and Principe ":"+239", "Kazakhstan ":"+7", "Peru ":"+51", "Kenya ":"+254", "Bonaire, Saint Eustatius and Saba  ":"+599", "Bahamas ":"+1-242", "Chad ":"+235", "Afghanistan ":"+93", "Luxembourg ":"+352", "Aruba ":"+297", "Tanzania ":"+255", "Palestinian Territory ":"+970", "South Africa ":"+27", "Grenada ":"+1-473", "Nicaragua ":"+505", "Belize ":"+501", "Greenland ":"+299", "Haiti ":"+509", "Cocos Islands ":"+61", "U.S. Virgin Islands ":"+1-340", "Togo ":"+228", "Gabon ":"+241", "Zambia ":"+260", "Tokelau ":"+690", "South Korea ":"+82", "Mali ":"+223", "Reunion ":"+262", "Nauru ":"+674", "Ghana ":"+233", "Iceland ":"+354", "Cuba ":"+53", "American Samoa ":"+1-684", "Tunisia ":"+216", "India ":"+91", "Panama ":"+507", "Iraq ":"+964", "Venezuela ":"+58", "Malaysia ":"+60", "Papua New Guinea ":"+675", "Egypt ":"+20", "Svalbard and Jan Mayen ":"+47", "Hong Kong ":"+852", "Netherlands ":"+31", "Kuwait ":"+965", "Oman ":"+968", "Mayotte ":"+262", "Saint Barthelemy ":"+590", "Belgium ":"+32", "Algeria ":"+213", "Taiwan ":"+886", "Gibraltar ":"+350", "French Polynesia ":"+689", "Montenegro ":"+382", "Czech Republic ":"+420", "Bhutan ":"+975", "Martinique ":"+596", "Swaziland ":"+268", "Vatican ":"+379", "Romania ":"+40", "Malawi ":"+265", "Jersey ":"+44-1534", "Moldova ":"+373", "Germany ":"+49", "Azerbaijan ":"+994", "Jamaica ":"+1-876", "Jordan ":"+962", "Montserrat ":"+1-664", "Christmas Island ":"+61", "San Marino ":"+378", "Kyrgyzstan ":"+996", "Sri Lanka ":"+94", "Somalia ":"+252", "Iran ":"+98", "Angola ":"+244", "Heard Island and McDonald Islands ":"+ ", "Finland ":"+358", "Western Sahara ":"+212", "Tonga ":"+676", "Saudi Arabia ":"+966", "Mauritania ":"+222", "Maldives ":"+960", "Lebanon ":"+961", "Nigeria ":"+234", "Armenia ":"+374", "Denmark ":"+45", "Australia ":"+61", "British Virgin Islands ":"+1-284", "New Caledonia ":"+687", "South Sudan ":"+211", "Guam ":"+1-671", "Burundi ":"+257", "Mexico ":"+52", "Japan ":"+81", "Uruguay ":"+598", "Cyprus ":"+357", "Liberia ":"+231", "United States ":"+1", "Comoros ":"+269", "Saint Vincent and the Grenadines ":"+1-784", "China ":"+86", "Cambodia ":"+855", "Pitcairn ":"+870", "Lithuania ":"+370", "Yemen ":"+967", "Tuvalu ":"+688", "Thailand ":"+66", "Bolivia ":"+591", "Bangladesh ":"+880", "New Zealand ":"+64", "Ethiopia ":"+251", "Bulgaria ":"+359", "Cape Verde ":"+238", "British Indian Ocean Territory ":"+246", "Niger ":"+227", "Estonia ":"+372", "Georgia ":"+995", "Saint Lucia ":"+1-758", "United Kingdom ":"+44", "Bahrain ":"+973", "Guinea ":"+224", "Guadeloupe ":"+590", "Malta ":"+356", "Albania ":"+355", "Samoa ":"+685", "Ivory Coast ":"+225", "Vietnam ":"+84", "Syria ":"+963", "Costa Rica ":"+506", "Israel ":"+972", "Rwanda ":"+250", "Fiji ":"+679", "Russia ":"+7", "Monaco ":"+377", "Hungary ":"+36", "Namibia ":"+264", "Zimbabwe ":"+263", "Paraguay ":"+595", "Chile ":"+56", "Botswana ":"+267", "Puerto Rico ":"+1-787", "Pakistan ":"+92", "Poland ":"+48", "France ":"+33", "Falkland Islands ":"+500", "Sweden ":"+46", "Saint Kitts and Nevis ":"+1-869", "United Arab Emirates ":"+971", "Wallis and Futuna ":"+681", "Burkina Faso ":"+226", "Qatar ":"+974", "Cook Islands ":"+682", "Saint Helena ":"+290", "Democratic Republic of the Congo ":"+243", "Equatorial Guinea ":"+240", "Ecuador ":"+593", "Micronesia ":"+691", "Faroe Islands ":"+298"]
    
    
    init() {
        
        currentCode = getCountryCode()
        allCodes = generateArrayOfCodes()
    }
    
    func generateArrayOfCodes() -> [String] {
        
        var separatedCodes = [""]
        for code in codeDictionary {
            
            separatedCodes.append("\(code.key) \(code.value)")
        }
        
        let sortedArray = separatedCodes.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        return sortedArray
    }
    
    func getCountryCode() -> String {
        
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        print("corrier is ??????\(carrier)")
        if carrier != nil {
            
            let countryCodeName = carrier?.isoCountryCode?.uppercased()
            
            //need to check in both dictionaries
            if countryCodeName != nil {
                let countryCodeShort = codeDictionaryShort["IN"]//countryCodeName!
                let countryCode = codeDictionary["India"]//countryCodeName!
                
                if  countryCodeShort != "" {
                    
                    return countryCodeShort!
                    
                } else if countryCode != ""{
                    
                    return countryCode!
                    
                }else {
                    print("no code......")
                    return ""
                    
                }

            } else {
                return ""
            }
            
        } else {
            return ""
        }
        
    }
}

