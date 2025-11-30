#!/usr/bin/env python3
"""
Comprehensive Indian Laws Database Updater
Fetches and updates the laws table in Supabase with comprehensive Indian laws data
"""

import os
import sys
import requests
import json
from typing import List, Dict
from datetime import datetime

# Comprehensive Indian Laws Database
INDIAN_LAWS = [
    # Constitutional Laws
    {
        "title": "Constitution of India",
        "description": "The supreme law of India. It lays down the framework defining fundamental political principles, establishes the structure, procedures, powers and duties of government institutions and sets out fundamental rights, directive principles and duties of citizens.",
        "category": "Constitutional",
        "year_enacted": 1950,
        "status": "Active",
        "official_url": "https://legislative.gov.in/constitution-of-india"
    },
    {
        "title": "Right to Information Act",
        "description": "Provides for setting out the practical regime of right to information for citizens to secure access to information under the control of public authorities.",
        "category": "Constitutional",
        "year_enacted": 2005,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2005-22.pdf"
    },
    {
        "title": "Right to Education Act",
        "description": "Provides for free and compulsory education to all children of age six to fourteen years.",
        "category": "Constitutional",
        "year_enacted": 2009,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2009-35.pdf"
    },
    {
        "title": "Scheduled Castes and Scheduled Tribes (Prevention of Atrocities) Act",
        "description": "Prevents atrocities against members of Scheduled Castes and Scheduled Tribes.",
        "category": "Constitutional",
        "year_enacted": 1989,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1989-33.pdf"
    },
    {
        "title": "Citizenship Act",
        "description": "Provides for acquisition and determination of citizenship.",
        "category": "Constitutional",
        "year_enacted": 1955,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1955-57.pdf"
    },
    {
        "title": "Protection of Human Rights Act",
        "description": "Provides for constitution of National Human Rights Commission, State Human Rights Commissions and Human Rights Courts for better protection of human rights.",
        "category": "Constitutional",
        "year_enacted": 1993,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1994-10.pdf"
    },
    
    # Criminal Laws
    {
        "title": "Indian Penal Code (IPC)",
        "description": "The main criminal code of India that covers all substantive aspects of criminal law. It defines crimes and provides punishments for almost all kinds of criminal and actionable wrongs.",
        "category": "Criminal",
        "year_enacted": 1860,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1860-45.pdf"
    },
    {
        "title": "Code of Criminal Procedure (CrPC)",
        "description": "The main legislation on procedural aspects of criminal law in India. It provides the machinery for the investigation of crime, apprehension of suspected criminals, collection of evidence, determination of guilt or innocence of the accused person and the determination of punishment.",
        "category": "Criminal",
        "year_enacted": 1973,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1974-2.pdf"
    },
    {
        "title": "Bharatiya Nyaya Sanhita (BNS)",
        "description": "Modern replacement for the Indian Penal Code. It modernizes criminal law provisions while retaining the essence of justice delivery. Effective from July 1, 2024.",
        "category": "Criminal",
        "year_enacted": 2023,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/sansad_TV/LS_bill39of2023_1.pdf"
    },
    {
        "title": "Indian Evidence Act",
        "description": "The law of evidence in India. It contains a set of rules and allied issues governing admissibility of evidence in Indian courts.",
        "category": "Criminal",
        "year_enacted": 1872,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1872-01.pdf"
    },
    {
        "title": "Prevention of Corruption Act",
        "description": "Consolidates and amends the law relating to prevention of corruption and matters connected therewith.",
        "category": "Criminal",
        "year_enacted": 1988,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1988-49.pdf"
    },
    {
        "title": "Protection of Children from Sexual Offences Act (POCSO)",
        "description": "Provides for protection of children from offences of sexual assault, sexual harassment and pornography.",
        "category": "Criminal",
        "year_enacted": 2012,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2012-32_0.pdf"
    },
    {
        "title": "Juvenile Justice (Care and Protection of Children) Act",
        "description": "Consolidates and amends the law relating to children alleged and found to be in conflict with law and children in need of care and protection.",
        "category": "Criminal",
        "year_enacted": 2015,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2016-2.pdf"
    },
    
    # Civil Laws
    {
        "title": "Code of Civil Procedure (CPC)",
        "description": "The procedural law governing civil litigation in India. It regulates every action of a civil court and parties until the execution of decree and order.",
        "category": "Civil",
        "year_enacted": 1908,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1908-05.pdf"
    },
    {
        "title": "Indian Contract Act",
        "description": "Regulates contracts in India and determines the circumstances in which promises made by parties to a contract shall be legally binding. It contains the general principles of contract law.",
        "category": "Civil",
        "year_enacted": 1872,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1872-09.pdf"
    },
    {
        "title": "Consumer Protection Act",
        "description": "Provides for protection of interests of consumers. It establishes authorities for timely and effective administration and settlement of consumer disputes.",
        "category": "Civil",
        "year_enacted": 2019,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2019-35.pdf"
    },
    {
        "title": "Motor Vehicles Act",
        "description": "Regulates all aspects of road transport vehicles. It deals with registration of vehicles, licensing of drivers, control of traffic, insurance, and compensation.",
        "category": "Civil",
        "year_enacted": 1988,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1988-59.pdf"
    },
    {
        "title": "Negotiable Instruments Act",
        "description": "Defines and amends the law relating to promissory notes, bills of exchange and cheques.",
        "category": "Civil",
        "year_enacted": 1881,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1881-26.pdf"
    },
    {
        "title": "Arbitration and Conciliation Act",
        "description": "Consolidates and amends the law relating to domestic arbitration, international commercial arbitration and enforcement of foreign arbitral awards.",
        "category": "Civil",
        "year_enacted": 1996,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1996-26.pdf"
    },
    {
        "title": "Environment Protection Act",
        "description": "Provides for protection and improvement of environment and for matters connected therewith.",
        "category": "Civil",
        "year_enacted": 1986,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1986-29.pdf"
    },
    
    # Property Laws
    {
        "title": "Transfer of Property Act",
        "description": "Defines and amends the law relating to transfer of property by act of parties. It deals with transfer of property between living persons.",
        "category": "Property",
        "year_enacted": 1882,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1882-04.pdf"
    },
    {
        "title": "Registration Act",
        "description": "Consolidates the law relating to registration of documents. It provides for registration of certain documents and matters connected therewith.",
        "category": "Property",
        "year_enacted": 1908,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1908-16_0.pdf"
    },
    {
        "title": "Land Acquisition Act",
        "description": "Provides for acquisition of land for public purposes and for matters connected therewith or incidental thereto.",
        "category": "Property",
        "year_enacted": 2013,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2013-30_0.pdf"
    },
    
    # Family Laws
    {
        "title": "Hindu Marriage Act",
        "description": "Codifies the law relating to marriage among Hindus. It deals with conditions for a Hindu Marriage, registration, divorce, judicial separation, restitution of conjugal rights and legitimacy of children.",
        "category": "Family",
        "year_enacted": 1955,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1955-25.pdf"
    },
    {
        "title": "Hindu Succession Act",
        "description": "Amends and codifies the law relating to intestate succession among Hindus. It deals with succession and inheritance of property.",
        "category": "Family",
        "year_enacted": 1956,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1956-30.pdf"
    },
    {
        "title": "Dowry Prohibition Act",
        "description": "Prohibits the giving or taking of dowry at or before or any time after the marriage. It provides for penalties for violation.",
        "category": "Family",
        "year_enacted": 1961,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1961-28.pdf"
    },
    {
        "title": "Protection of Women from Domestic Violence Act",
        "description": "Provides for protection of women from domestic violence and matters connected therewith or incidental thereto.",
        "category": "Family",
        "year_enacted": 2005,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2005-43.pdf"
    },
    {
        "title": "Muslim Personal Law (Shariat) Application Act",
        "description": "Provides for the application of Muslim personal law to Muslims in matters of succession, inheritance, marriage and others.",
        "category": "Family",
        "year_enacted": 1937,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1937-26.pdf"
    },
    {
        "title": "Hindu Adoption and Maintenance Act",
        "description": "Amends and codifies the law relating to adoptions and maintenance among Hindus.",
        "category": "Family",
        "year_enacted": 1956,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1956-78.pdf"
    },
    {
        "title": "Special Marriage Act",
        "description": "Provides a special form of marriage in certain cases and for registration of certain marriages. It applies to all citizens of India.",
        "category": "Family",
        "year_enacted": 1954,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1954-43.pdf"
    },
    {
        "title": "Indian Divorce Act",
        "description": "Amends and consolidates the law relating to divorce among Christians.",
        "category": "Family",
        "year_enacted": 1869,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1869-04.pdf"
    },
    
    # Labor and Employment Laws
    {
        "title": "Minimum Wages Act",
        "description": "Provides for minimum rates of wages in certain employments. It aims to prevent exploitation of workers.",
        "category": "Labor",
        "year_enacted": 1948,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1948-11.pdf"
    },
    {
        "title": "Payment of Bonus Act",
        "description": "Provides for payment of bonus to employees in certain establishments on the basis of profits or productivity.",
        "category": "Labor",
        "year_enacted": 1965,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1965-21_0.pdf"
    },
    {
        "title": "Industrial Disputes Act",
        "description": "Provides for investigation and settlement of industrial disputes. It regulates strikes, lockouts, layoffs and retrenchments.",
        "category": "Labor",
        "year_enacted": 1947,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1947-14.pdf"
    },
    {
        "title": "Employees Provident Funds and Miscellaneous Provisions Act",
        "description": "Provides for institution of provident funds, family pension fund and deposit-linked insurance fund for employees.",
        "category": "Labor",
        "year_enacted": 1952,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1952-19.pdf"
    },
    {
        "title": "Employees State Insurance Act",
        "description": "Provides for certain benefits to employees in case of sickness, maternity and employment injury.",
        "category": "Labor",
        "year_enacted": 1948,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1948-34.pdf"
    },
    {
        "title": "Payment of Gratuity Act",
        "description": "Provides for payment of gratuity to employees engaged in factories, mines, oilfields, plantations, ports, railway companies, shops or other establishments.",
        "category": "Labor",
        "year_enacted": 1972,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1972-39.pdf"
    },
    {
        "title": "Factories Act",
        "description": "Regulates labour in factories. It provides for health, safety, welfare, working hours, leave and other matters in relation to workers employed therein.",
        "category": "Labor",
        "year_enacted": 1948,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1948-63.pdf"
    },
    {
        "title": "Sexual Harassment of Women at Workplace Act",
        "description": "Provides for protection against sexual harassment of women at workplace and prevention and redressal of complaints.",
        "category": "Labor",
        "year_enacted": 2013,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2013-14_0.pdf"
    },
    
    # Tax Laws
    {
        "title": "Income Tax Act",
        "description": "The charging statute of Income Tax in India. It provides for levy, administration, collection and recovery of Income Tax.",
        "category": "Tax",
        "year_enacted": 1961,
        "status": "Active",
        "official_url": "https://incometaxindia.gov.in/pages/acts/income-tax-act.aspx"
    },
    {
        "title": "Central Goods and Services Tax Act (CGST)",
        "description": "Provides for levy and collection of tax on intra-state supply of goods or services or both by the Central Government.",
        "category": "Tax",
        "year_enacted": 2017,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2017-12.pdf"
    },
    {
        "title": "Customs Act",
        "description": "Consolidates and amends the law relating to customs. It regulates imports and exports, and levies customs duties.",
        "category": "Tax",
        "year_enacted": 1962,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1962-52_0.pdf"
    },
    {
        "title": "Integrated Goods and Services Tax Act (IGST)",
        "description": "Provides for levy and collection of tax on inter-state supply of goods or services or both.",
        "category": "Tax",
        "year_enacted": 2017,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2017-13.pdf"
    },
    
    # Corporate Laws
    {
        "title": "Companies Act",
        "description": "Consolidates and amends the law relating to companies. It regulates incorporation, responsibilities, directors, dissolution, and winding up of companies.",
        "category": "Corporate",
        "year_enacted": 2013,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2013-18.pdf"
    },
    {
        "title": "Limited Liability Partnership Act",
        "description": "Provides for the formation and regulation of limited liability partnerships.",
        "category": "Corporate",
        "year_enacted": 2008,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2009-6.pdf"
    },
    {
        "title": "Securities and Exchange Board of India Act",
        "description": "Provides for establishment of Securities and Exchange Board of India to protect interests of investors in securities and to regulate the securities market.",
        "category": "Corporate",
        "year_enacted": 1992,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A1992-15.pdf"
    },
    {
        "title": "Competition Act",
        "description": "Provides for establishment of Competition Commission of India to prevent practices having adverse effect on competition and to promote and sustain competition in markets.",
        "category": "Corporate",
        "year_enacted": 2002,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2003-12.pdf"
    },
    
    # Cyber and IT Laws
    {
        "title": "Information Technology Act",
        "description": "Provides legal recognition for transactions carried out by electronic data interchange and electronic communication. It deals with cybercrimes and electronic commerce.",
        "category": "Cyber",
        "year_enacted": 2000,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2000-21.pdf"
    },
    {
        "title": "Digital Personal Data Protection Act",
        "description": "Provides for the processing of digital personal data in a manner that recognizes both the right of individuals to protect their personal data and the need to process such data for lawful purposes.",
        "category": "Cyber",
        "year_enacted": 2023,
        "status": "Active",
        "official_url": "https://legislative.gov.in/sites/default/files/A2023-22.pdf"
    },
]


def upsert_laws_to_supabase(laws: List[Dict], supabase_url: str, service_key: str) -> None:
    """
    Upsert laws to Supabase database
    Uses title as unique identifier to prevent duplicates
    """
    headers = {
        "apikey": service_key,
        "Authorization": f"Bearer {service_key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates"
    }
    
    endpoint = f"{supabase_url}/rest/v1/laws"
    
    success_count = 0
    error_count = 0
    
    for law in laws:
        try:
            # Check if law already exists
            check_url = f"{endpoint}?title=eq.{requests.utils.quote(law['title'])}"
            check_response = requests.get(check_url, headers=headers)
            
            if check_response.status_code == 200 and len(check_response.json()) > 0:
                # Update existing law
                existing_law = check_response.json()[0]
                law_id = existing_law['id']
                update_url = f"{endpoint}?id=eq.{law_id}"
                response = requests.patch(update_url, headers=headers, json=law)
                action = "Updated"
            else:
                # Insert new law
                response = requests.post(endpoint, headers=headers, json=law)
                action = "Inserted"
            
            if response.status_code in [200, 201, 204]:
                print(f"✅ {action}: {law['title']}")
                success_count += 1
            else:
                print(f"❌ Error with {law['title']}: {response.status_code} - {response.text}")
                error_count += 1
                
        except Exception as e:
            print(f"❌ Exception with {law['title']}: {str(e)}")
            error_count += 1
    
    print(f"\n📊 Summary:")
    print(f"   ✅ Successful: {success_count}")
    print(f"   ❌ Failed: {error_count}")
    print(f"   📚 Total: {len(laws)}")


def main():
    """Main execution function"""
    print("🚀 Starting Indian Laws Database Update...")
    print(f"⏰ Timestamp: {datetime.now().isoformat()}\n")
    
    # Get environment variables
    supabase_url = os.getenv("SUPABASE_URL")
    service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    
    if not supabase_url or not service_key:
        print("❌ Error: Missing required environment variables")
        print("   Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY")
        sys.exit(1)
    
    # Remove trailing slash from URL if present
    supabase_url = supabase_url.rstrip('/')
    
    print(f"🔗 Supabase URL: {supabase_url}")
    print(f"📚 Total laws to process: {len(INDIAN_LAWS)}\n")
    
    # Upsert laws to database
    upsert_laws_to_supabase(INDIAN_LAWS, supabase_url, service_key)
    
    print("\n✅ Laws database update completed!")


if __name__ == "__main__":
    main()
