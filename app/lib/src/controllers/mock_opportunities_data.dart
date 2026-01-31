class MockOpportunitiesData {
  static final Map<String, dynamic> overviewData = {
    "dashboard_hero": {
      "total_opportunity_value": 1520000.0,
      "formatted_value": "₹15.2 Lakhs",
      "executive_summary":
          "You have significant opportunities across insurance, SIP recovery, and portfolio rebalancing to help your clients maximize their wealth.",
      "opportunity_breakdown": {
        "insurance": "₹10L",
        "sip_recovery": "₹5L",
        "portfolio_rebalancing": "₹20K"
      }
    },
    "top_focus_clients": [
      {
        "user_id": "user123",
        "client_name": "Rajesh Kumar",
        "total_impact_value": "₹1.5 L",
        "tags": ["Risk: Stopped SIP", "Opp: Insurance"],
        "pitch_hook":
            "3 SIPs stopped for 6+ months. Missing ₹75K insurance coverage on ₹28L portfolio.",
        "drill_down_details": {
          "portfolio_review": {
            "has_issue": true,
            "schemes": [
              {"name": "HDFC Mid-Cap", "xirr_lag": -4.5}
            ]
          },
          "sip_health": {
            "stopped_sips": [
              {
                "scheme": "ICICI Value Discovery",
                "days_stopped": 180,
                "amount": 5000.0
              }
            ],
            "stagnant_sips": [
              {"scheme": "SBI Bluechip", "years_running": 3.5}
            ]
          },
          "insurance": {
            "has_gap": true,
            "gap_amount": 75000.0,
            "wealth_band": "HNI"
          }
        }
      },
      {
        "user_id": "user456",
        "client_name": "Priya Sharma",
        "total_impact_value": "₹2.1 L",
        "tags": ["Opp: Portfolio Review", "Opp: Insurance"],
        "pitch_hook":
            "5 funds underperforming benchmark by avg 6.2%. Insurance gap of ₹1.2L identified.",
        "drill_down_details": {
          "portfolio_review": {
            "has_issue": true,
            "schemes": [
              {"name": "DSP Healthcare", "xirr_lag": -8.1},
              {"name": "Kotak Midcap", "xirr_lag": -4.3}
            ]
          },
          "sip_health": {"stopped_sips": [], "stagnant_sips": []},
          "insurance": {
            "has_gap": true,
            "gap_amount": 120000.0,
            "wealth_band": "Ultra HNI"
          }
        }
      }
    ]
  };

  static final Map<String, dynamic> portfolioData = {
    "total_clients": 1,
    "total_underperforming_schemes": 2,
    "total_value_underperforming": 1507177.27,
    "clients": [
      {
        "user_id": "017b9fb6-ef3f-490b-8954-c731bd360e4f",
        "client_name": "RAJESH KUMAR",
        "agent_external_id": "ag_DBpVTiu6Z3iQdBXZ8XiMDE",
        "agent_name": "RAJIV KUMAR SHAW",
        "number_of_underperforming_schemes": 2,
        "total_value_underperforming": 1507177.27,
        "underperforming_schemes": [
          {
            "wpc": "MF00001624",
            "scheme_name": "DSP Midcap Fund (G)",
            "live_xirr": 12.2952,
            "benchmark_xirr": 16.9898,
            "xirr_underperformance": -4.69,
            "current_value": 979087.62,
            "benchmark_name": "Nifty MidCap 150",
            "category": "Mid Cap Fund",
            "amc_name": "DSP"
          },
          {
            "wpc": "MF00005564",
            "scheme_name": "DSP Healthcare Fund (G)",
            "live_xirr": 11.8249,
            "benchmark_xirr": 12.3128,
            "xirr_underperformance": -0.49,
            "current_value": 528089.65,
            "benchmark_name": "Nifty 500",
            "category": "Sectoral / Thematic",
            "amc_name": "DSP"
          }
        ]
      }
    ]
  };

  static final Map<String, dynamic> stagnantSipData = {
    "total_stagnant_sips": 3,
    "total_clients_affected": 3,
    "total_sip_value": 19500.0,
    "opportunities": [
      {
        "user_id": "ffeed544-3be4-4108-a534-361c58746a77",
        "user_name": "PRADNYA CHANDRAKANT GAIKWAD",
        "agent_id": "76352",
        "agent_external_id": "ag_YvJkGSgtTQKsYPxkTcCUCN",
        "agent_name": "I4I INVESTMENT SERVICES PRIVATE LIMITED",
        "sip_meta_id": "85",
        "scheme_name": "HDFC Mid-Cap Opportunities Fund (G)",
        "current_sip": 7500.0,
        "created_at": "2023-07-30T19:02:00",
        "months_stagnant": 30,
        "success_amount": 137500.0
      },
      {
        "user_id": "00c1c445-7dfd-4c49-ba19-49f32254b623",
        "user_name": "SEEMA AJAY SURVE",
        "agent_id": "76352",
        "agent_external_id": "ag_YvJkGSgtTQKsYPxkTcCUCN",
        "agent_name": "I4I INVESTMENT SERVICES PRIVATE LIMITED",
        "sip_meta_id": "116",
        "scheme_name": "HDFC Flexi Cap Fund - (G)",
        "current_sip": 5000.0,
        "created_at": "2023-07-30T19:52:00",
        "months_stagnant": 30,
        "success_amount": 160000.0
      },
      {
        "user_id": "089a4379-dc96-490f-b892-223e74fd2f0e",
        "user_name": "CHINMAY BHASKAR SUPE",
        "agent_id": "76352",
        "agent_external_id": "ag_YvJkGSgtTQKsYPxkTcCUCN",
        "agent_name": "I4I INVESTMENT SERVICES PRIVATE LIMITED",
        "sip_meta_id": "302",
        "scheme_name": "HDFC Focused 30 Fund (G)",
        "current_sip": 7000.0,
        "created_at": "2023-07-30T19:53:00",
        "months_stagnant": 30,
        "success_amount": 160000.0
      }
    ]
  };

  static final Map<String, dynamic> stoppedSipData = {
    "total_stopped_clients": 100,
    "total_active_sips_affected": 143,
    "total_lifetime_investment": 3853150.0,
    "average_days_inactive": 273.2,
    "opportunities": [
      {
        "user_id": "0633e46d-1946-4245-b982-e2d672f3bdc9",
        "user_name": "DINESH BHAVANISHANKAR SHAH",
        "agent_external_id": "ag_xEaoi9X5BiiHaacd6EJNud",
        "agent_name": "MONIKA SHAH",
        "total_sips": 1,
        "active_sips": 1,
        "max_success_count": 5,
        "lifetime_success_amount": 5000.0,
        "last_success_date": "2023-09-10",
        "days_since_any_success": 873,
        "months_since_success": 29
      },
      {
        "user_id": "9f86d781-e70f-491c-a25b-ee1acaa60c2b",
        "user_name": "DAYANAND SIRSANGI",
        "agent_external_id": "ag_tyA9RqYNWKGX6JeMryC5hF",
        "agent_name": "SAGAR APPASAB PATIL",
        "total_sips": 1,
        "active_sips": 1,
        "max_success_count": 6,
        "lifetime_success_amount": 9000.0,
        "last_success_date": "2023-12-02",
        "days_since_any_success": 790,
        "months_since_success": 26
      },
      {
        "user_id": "14b94353-24e1-4cc2-96f7-8a2e406030fe",
        "user_name": "AMZAD HUSSAIN",
        "agent_external_id": "ag_VJBXnYJWuwenBi7ULzk9iW",
        "agent_name": "MANJUR AHMED BHUYAN",
        "total_sips": 1,
        "active_sips": 1,
        "max_success_count": 8,
        "lifetime_success_amount": 8000.0,
        "last_success_date": "2024-01-05",
        "days_since_any_success": 756,
        "months_since_success": 25
      },
      {
        "user_id": "1262768c-e4fe-474b-aff5-fdd344f63748",
        "user_name": "RATHOD RAKESHKUMAR",
        "agent_external_id": "ag_NATgNHyKoNxNhyxkm7ibnE",
        "agent_name": "HARDIKKUMAR KACHARABHAI PRAJAPATI",
        "total_sips": 1,
        "active_sips": 1,
        "max_success_count": 10,
        "lifetime_success_amount": 47000.0,
        "last_success_date": "2024-02-05",
        "days_since_any_success": 725,
        "months_since_success": 24
      }
    ]
  };

  static final Map<String, dynamic> insuranceData = {
    "total_opportunities": 2,
    "no_insurance_count": 2,
    "low_coverage_count": 0,
    "total_opportunity_value": 119358.13,
    "total_mf_value_at_risk": 39786042.25,
    "average_age": 67.5,
    "opportunities": [
      {
        "user_id": "f70539a5-fd7b-45e5-a358-2f080cdfdb43",
        "user_name": "KAYUR MEHTA",
        "agent_external_id": "ag_orcFbFRQDJ9aLUNAfpW7K3",
        "agent_name": "NANDINI BANERJEE JHA",
        "age": 68,
        "mf_current_value": 28628139.98,
        "total_premium": 0.0,
        "expected_premium": 85884.42,
        "insurance_status": "NO_INSURANCE",
        "premium_opportunity_value": 85884.42,
        "coverage_percentage": 0.0
      },
      {
        "user_id": "3d313363-df3b-4023-b926-3a10ebd953cb",
        "user_name": "ANUPAM DUTTA",
        "agent_external_id": "ag_orcFbFRQDJ9aLUNAfpW7K3",
        "agent_name": "NANDINI BANERJEE JHA",
        "age": 67,
        "mf_current_value": 11157902.27,
        "total_premium": 0.0,
        "expected_premium": 33473.71,
        "insurance_status": "NO_INSURANCE",
        "premium_opportunity_value": 33473.71,
        "coverage_percentage": 0.0
      }
    ]
  };
}
