require 'elasticsearch'

class ResultsController < ApplicationController
    def index 

        client = Elasticsearch::Client.new url: "https://#{ENV["PASSWORD"]}:#{ENV["USERNAME"]}@sample.es.streem.com.au:9243", log: true

        if params[:query] && params[:before] && params[:after] && params[:interval]
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

        else 
          render json: {status: "error", code: 3000, message: "Can't execute api request without query, before, after and interval data"}
        end
    end
end


