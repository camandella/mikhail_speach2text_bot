# frozen_string_literal: true

require 'telegram/bot'

class BotService
  class << self
    def call
      Telegram::Bot::Client.run(telegram_bot_token) do |bot|
        bot.listen do |message|
          chat_id = message.chat.id

          begin
            case message.text
            when '/start'
              bot.api.send_message(chat_id: chat_id, text: I18n.t('send_your_voice_message'))
            else
              if message.voice&.file_id
                voice_file_path = bot.api.get_file(file_id: message.voice.file_id).dig('result', 'file_path')
                voice_file_url = telegram_voice_file_url(voice_file_path)
                voice_data = RestClient.get(voice_file_url).body

                speech_recognize_response = RestClient.post(
                  yandex_speech_recognize_url,
                  voice_data,
                  Authorization: "Bearer #{iam_token}"
                )
                speech_recognize_result = JSON.parse(speech_recognize_response.body)['result']

                bot.api.send_message(chat_id: chat_id, text: speech_recognize_result)
              else
                bot.api.send_message(chat_id: chat_id, text: I18n.t('this_is_not_a_voice_message'))
              end
            end
          rescue StandardError
            bot.api.send_message(chat_id: chat_id, text: I18n.t('an_error_occured'))
          end 
        end
      end
    end

    private

    def telegram_bot_token
      @telegram_bot_token ||= ENV['TELEGRAM_BOT_TOKEN']
    end

    def iam_token
      @iam_token ||= ENV['IAM_TOKEN']
    end

    def yandex_speech_recognize_url
      @yandex_speech_recognize_url ||=
        "https://stt.api.cloud.yandex.net/speech/v1/stt:recognize?folderId=#{yandex_speech_recognize_folder_id}&lang=ru-RU"
    end

    def yandex_speech_recognize_folder_id
      ENV['YANDEX_SPEECH_RECOGNIZE_FOLDER_ID']
    end

    def telegram_voice_file_url(voice_file_path)
      "https://api.telegram.org/file/bot#{telegram_bot_token}/#{voice_file_path}"
    end
  end
end
