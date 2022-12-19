# frozen_string_literal: true

class BotController < ApplicationController

  @@bot_thread = nil

  def start
    if @@bot_thread&.alive?
      status = 'alredy_running'
    else 
      @@bot_thread = Thread.new { BotService.call }
      status = 'ok'
    end
    render json: { status: status }
  end

  def state
    render json: { status: (@@bot_thread&.alive? ? 'running' : 'not_running') }
  end

  def stop
    if @@bot_thread
      @@bot_thread.kill
      @@bot_thread = nil
      status = 'ok'
    else
      status = 'nothing_to_stop'
    end
    render json: { status: status }
  end
end
