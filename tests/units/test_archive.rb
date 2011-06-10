#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_helper'

class TestArchive < Test::Unit::TestCase
  
  def setup
    set_file_paths
    @git = Git.open(@wdir)
  end
  
  def tempfile_path
    @tempfile ||= Tempfile.new('archive-test')
    @tempfile.path
  end

  def teardown
    @tempfile.close!
  end
  
  def tempfile_dirname
    @tempfile_dirname ||= File.dirname(tempfile_path)
  end

  def test_archive
    f = @git.archive('v2.6', tempfile_path)
    assert(File.exists?(f))

    f = @git.object('v2.6').archive(tempfile_path)  # writes to given file
    assert(File.exists?(f))

    f = @git.object('v2.6').archive # returns path to temp file
    assert(File.exists?(f))
    
    f = @git.object('v2.6').archive(nil, :format => 'tar') # returns path to temp file
    assert(File.exists?(f))
   
    `cd #{tempfile_dirname}; tar xvpf #{f}`
    ext_dir = File.join tempfile_dirname, 'ex_dir'
    ext_file = File.join tempfile_dirname, 'example.txt'
    assert File.directory? ext_dir
    assert File.exists? ext_file
    
    f = @git.object('v2.6').archive(tempfile_path, :format => 'zip')
    assert(File.file?(f))

    f = @git.object('v2.6').archive(tempfile_path, :format => 'tgz', :prefix => 'test/')
    assert(File.exists?(f))
    
    f = @git.object('v2.6').archive(tempfile_path, :format => 'tar', :prefix => 'test/', :path => 'ex_dir/')
    assert(File.exists?(f))
    
    `cd #{tempfile_dirname}; tar xvpf #{f}`
    ext_dir = File.join tempfile_dirname, 'test'
    ext_file = File.join tempfile_dirname, 'test', 'ex_dir', 'ex.txt'
    assert File.directory? ext_dir
    assert File.exists? ext_file

    in_temp_dir do
      c = Git.clone(@wbare, 'new')
      c.chdir do
        f = c.remote('origin').branch('master').archive(tempfile_path, :format => 'tgz')
        assert(File.exists?(f))
      end
    end
  end
  
end
