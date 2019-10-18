require 'elasticsearch'

class ResultsController < ApplicationController
    def index 

        # Debugging 
        # p "HERE ARE THE PARAMS", params[:query], params[:before], params[:after], params[:interval]

        client = Elasticsearch::Client.new url: 'https://elastic:streem@sample.es.streem.com.au:9243', log: true

        results = client.search index: 'news',
                          body: {
                            "aggs": {
                              "2": {
                                "date_histogram": {
                                  "field": "timestamp",
                                  "fixed_interval": "#{params[:interval]}",
                                  "time_zone": "Australia/Sydney",
                                  "min_doc_count": 1
                                },
                                "aggs": {
                                  "3": {
                                    "terms": {
                                      "field": "medium",
                                      "order": {
                                        "_count": "desc"
                                      },
                                      "size": 5
                                    }
                                  }
                                }
                              }
                            },
                            "size": 0,
                            "_source": {
                              "excludes": []
                            },
                            "stored_fields": [
                              "*"
                            ],
                            "script_fields": {},
                            "docvalue_fields": [
                              {
                                "field": "timestamp",
                                "format": "date_time"
                              }
                            ],
                            "query": {
                              "bool": {
                                "must": [
                                  {
                                    "range": {
                                      "timestamp": {
                                        "format": "epoch_millis",
                                        "gte": "#{params[:after]}",
                                        "lte": "#{params[:before]}"
                                      }
                                    }
                                  }
                                ],
                                "filter": [
                                  {
                                    "multi_match": {
                                      "type": "best_fields",
                                      "query": "#{params[:query]}",
                                      "lenient": true
                                    }
                                  }
                                ],
                                "should": [],
                                "must_not": []
                              }
                            }
                          }

        render json: results
    end


    private
    def result_params
        params.permit(:query, :before, :after, :interval)
    end
end


