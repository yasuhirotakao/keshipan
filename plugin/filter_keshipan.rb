# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'fluent/plugin/filter'
require 'fluent/config/error'
require 'fluent/plugin/string_util'
require 'syslog/logger'
require 'json'

module Fluent::Plugin
  class GrepFilter < Filter
    Fluent::Plugin.register_filter('keshipan', self)
    @@single_byte_dict_condtions=[]
    @@multi_byte_dict_condtions=[]
    @@email_check=false
    @@pan_check=false
    @@bin_regex_condtions=[]
    @@syslog = Syslog::Logger.new 'fluent/keshipan'
    @@syslog.info 'this line will be logged via syslog(3)'
    def initialize
      super
      @@dict_condtions=[]
      log.info "keshipan initialize"
    end

    helpers :record_accessor

    def configure(conf)
      super
      log.info "keshipan configure"
      count=0
      File.open(conf["single_byte_file"], mode = "rt"){|f|
           f.each_line{|line|
	       line.chomp!
	       if line.start_with?("#") == false and line.length>0
	           @@single_byte_dict_condtions.push(line.to_s.downcase.force_encoding('UTF-8'))
                   count+=1
	       end
           }
      }
      log.info @@single_byte_dict_condtions
      log.info "single_byte_file:"+conf["single_byte_file"] + " " +count.to_s
      count=0
      File.open(conf["multi_byte_file"], mode = "rt"){|f|
           f.each_line{|line|
	       line.chomp!
	       if line.start_with?("#") == false and line.length>0
	           @@multi_byte_dict_condtions.push(line.to_s.downcase.force_encoding('UTF-8'))
                   count+=1
	       end
           }
      }
      log.info @@multi_byte_dict_condtions
      log.info "multi_byte_file:"+conf["multi_byte_file"] + " "+count.to_s
      if conf["email_check"] == "true"
	  @@email_check = true
          log.info "email_check is true"
      end
      if conf["pan_check"] == "true"
	  @@pan_check = true
          log.info "pan_check is true"
          count=0
          File.open(conf["bin_file"], mode = "rt"){|f|
               f.each_line{|line|
                   line.chomp!
		   if line.start_with?("#") == false and line.length>0
                       @@bin_regex_condtions.push(line)
		       count+=1
	           end
               }
               log.info @@bin_regex_condtions
          }
          log.info "bin_file:"+conf["bin_file"] + " "+count.to_s
      end
    end
    # ある文字列がマルチバイト文字を含んでいるか
    def has_mb?(str)
        str.bytes do |b|
            return true if  (b & 0b10000000) != 0
        end
        return false
    end

    def filter(tag, time, record)
      personal_info_flg=false
      #ひらがな　カタカナ　漢字　氏名　地名
      if @@single_byte_dict_condtions.size>0 
          match_flg=false
          msg=record["message"].to_s.downcase
	  @@single_byte_dict_condtions.each { |word| 
	      if msg.gsub!(word,'***single byte match***') 
                   match_flg=true
              end
	  }
          if match_flg
	     personal_info_flg=true
	     record["message"]=msg
          end
      end
      #ひらがな　カタカナ　漢字　氏名　地名
      if @@multi_byte_dict_condtions.size>0 
          if has_mb?(record["message"]) 
              match_flg=false
              msg=record["message"].to_s.force_encoding('UTF-8')
              @@multi_byte_dict_condtions.each { |word| 
    	          if msg.gsub!(word,'***multi byte match***') 
                       match_flg=true
                  end
    	      }
              if match_flg
                  personal_info_flg=true
                  record["message"]=msg
              end
          end
      end
      if @@email_check
          msg=record["message"].to_s.downcase
	  if msg.gsub!(/([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/,"***email match***")
	      personal_info_flg=true
	      record["message"]=msg
	  end   
      end   
      if @@pan_check
	  msg=record["message"].to_s
          match_flg=false
	  @@bin_regex_condtions.each { |jouken| 
	      if msg.gsub!(/#{jouken}/,"***pan match****")
                  match_flg=true
	      end   
	  }
          if match_flg
	     personal_info_flg=true
	     record["message"]=msg
          end
      end 
      if personal_info_flg
	  @@syslog.error "KESHIPAN personal info match!! msg:"+JSON.generate(record)
      end
      return record
    end

    Expression = Struct.new(:key, :pattern) do
      def match?(record)
        ::Fluent::StringUtil.match_regexp(pattern, key.call(record).to_s)
      end
    end
  end
end
