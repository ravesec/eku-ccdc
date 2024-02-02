# WHEN COMPILING TO EXE MAKE SURE TO INCLUDE -requireAdmin
# Authors: Logan Jackson and Raven Dean

# Imports
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

#Check for correct OS
#if((Get-WmiObject Win32_OperatingSystem).Caption -notlike "*2012*" -or (Get-WmiObject Win32_OperatingSystem).Caption -notlike "*2016*")
#{
#  [System.Windows.MessageBox]::Show("Error: Incorrect Operating System","Error",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
#  Exit 2
#}

## Check for correct version of .NET (# Requires was introduced in WMF 4.0)
#if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "379893")
#{
#  [System.Windows.MessageBox]::Show("Error: Incorrect .NET Framework","Error",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
#  Exit 3
#}
#
## Check for correct version of WMF (Just in case :/)
#if($PSVersionTable.PSVersion.Major -lt "5" -and $PSVersionTable.PSVersion.Minor -lt "1")
#{
#  [System.Windows.MessageBox]::Show("Error: Incorrect Powershell Version","Error",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error) | Out-Null
#  Exit 4
#}

# BELOW CHECK NOT LEGAL FOR COMP

<#

# Make sure no snoops
$snoopForm = [System.Windows.Forms.Form] @{ TopMost = $true; Text = "Good Luck :)"; FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog; MinimizeBox = $false; MaximizeBox = $false; Width = 400; Height = 200; StartPosition = "CenterScreen"}
$snoopForm.Controls.AddRange(
  @(
    [System.Windows.Forms.Label] @{ Name = 'user'; AutoSize = $true; Font = New-Object System.Drawing.Font("Comic Sans MS", 10); Text = 'Username:'; Top = 25 ; Left = 25 }
    [System.Windows.Forms.Label] @{ Name = 'pass'; AutoSize = $true; Font = New-Object System.Drawing.Font("Comic Sans MS", 10); Text = 'Password:'; Top = 50; Left = 25 }
    [System.Windows.Forms.TextBox] @{ Name = 'username'; Font = New-Object System.Drawing.Font("Comic Sans MS", 10); Top = 25; Left = 125; Width = 225 }
    [System.Windows.Forms.TextBox] @{ Name = 'password'; Font = New-Object System.Drawing.Font("Comic Sans MS", 10); PasswordChar = '*'; Top = 50; Left = 125; Width = 225 }
    [System.Windows.Forms.Button] @{ Name = 'submit'; Font = New-Object System.Drawing.Font("Comic Sans MS", 10); AutoSize = $true; Text = 'Submit?'; Top = 100; Left = 275 }
  ))

function Submit_Click
{ 
  $username = $snoopForm.Controls['username'].Text
  $string = $snoopForm.Controls['password'].Text
  $stream = [IO.MemoryStream]::new([byte[]][char[]]$string)
  
  if(($username -eq 'admin') -and (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash -eq "5E884898DA28047151D0E56F8DC6292773603D0D6AABBDD62A11EF721D1542D8")
  {
    $snoopForm.Dispose()
    $script:continue = $true
  }
  else
  {
    [System.Windows.MessageBox]::Show("L bozo","Error",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    $snoopForm.Dispose()
    $script:continue = $false
  }
}

$snoopForm.Controls['submit'].Add_Click({ Submit_Click })

$snoopForm.Controls['username'].Add_KeyDown(
{
  if($_.KeyCode -eq "Enter")
  {
    $snoopForm.Controls['password'].Focus()
  }
})

$snoopForm.Controls['password'].Add_KeyDown(
{
  if($_.KeyCode -eq "Enter")
  {
    Submit_Click
  }
})

$continue = $false
$snoopForm.ShowDialog() | Out-Null


if(!$continue)
{
  Exit 1
}

#>

# XML

[xml]$xamlMain = @"
<Window 
    x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="Windows Server 2012 Hardening" 
    SizeToContent="WidthAndHeight"
    ResizeMode="CanMinimize"
    Background="#FF2D2D30">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="Padding" Value="14"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#FF686868"/>
    </Style>
    <Style TargetType="TabControl">
      <Setter Property="Background" Value="Transparent"/>
    </Style>
    <Style TargetType="TabItem">
      <Setter Property="Background" Value="#FF2D2D30"/>
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="Padding" Value="20"/>
    </Style>
  </Window.Resources>
  <Grid>
    <TabControl Margin="10">
      <TabItem Header="Firewall Tools">
        <Grid Background="#FF2D2D30">
          <StackPanel Orientation="Vertical">
            <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="Red" Margin="10">
            <Run Text=" █████▒  ██▓ ██▀███  ▓█████  █     █░ ▄▄▄       ██▓     ██▓    "/>
            <LineBreak/>
            <Run Text="▓██   ▒ ▓██▒▓██ ▒ ██▒▓█   ▀ ▓█░ █ ░█░▒████▄    ▓██▒    ▓██▒    "/>
            <LineBreak/>
            <Run Text="▒████ ░ ▒██▒▓██ ░▄█ ▒▒███   ▒█░ █ ░█ ▒██  ▀█▄  ▒██░    ▒██░    "/>
            <LineBreak/>
            <Run Text="░▓█▒  ░ ░██░▒██▀▀█▄  ▒▓█  ▄ ░█░ █ ░█ ░██▄▄▄▄██ ▒██░    ▒██░    "/>
            <LineBreak/>
            <Run Text="░▒█░    ░██░░██▓ ▒██▒░▒████▒░░██▒██▓  ▓█   ▓██▒░██████▒░██████▒"/>
            <LineBreak/>
            <Run Text=" ▒ ░    ░▓  ░ ▒▓ ░▒▓░░░ ▒░ ░░ ▓░▒ ▒   ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░"/>
            <LineBreak/>
            <Run Text=" ░       ▒ ░  ░▒ ░ ▒░ ░ ░  ░  ▒ ░ ░    ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░"/>
            <LineBreak/>
            <Run Text=" ░ ░     ▒ ░  ░░   ░    ░     ░   ░    ░   ▒     ░ ░     ░ ░   "/>
            <LineBreak/>
            <Run Text="         ░     ░        ░  ░    ░          ░  ░    ░  ░    ░  ░"/>
            <LineBreak/>
            </TextBlock>
            <Button x:Name="FireWallKickstarter">Kickstarter for AD/DNS/DHCP</Button>
            <Button x:Name="CreateRule">Create a Rule</Button>
            <Button x:Name="ModifyRule">Modify a Rule</Button>
            <Button x:Name="CodeRed">Code Red</Button>
          </StackPanel>
        </Grid>
      </TabItem>
      <TabItem Header="Active Directory">
        <Grid Background="#FF2D2D30">
          <StackPanel Orientation="Vertical">
            <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="White" Margin="10">
                <Run Text="      db      `7MM&amp;&quot;Yb.   "/>
                <LineBreak/>   
                <Run Text="     ;MM:       MM    `Yb. "/>
                <LineBreak/>  
                <Run Text="    ,V^MM.      MM     `Mb "/>
                <LineBreak/>  
                <Run Text="   ,M  `MM       MM     MM "/>
                <LineBreak/>  
                <Run Text="   AbmmmqMA     MM    ,MP "/>
                <LineBreak/>  
                <Run Text="  A'     VML    MM   ,dP' "/>
                <LineBreak/>  
                <Run Text=".AMA.   .AMMA..JMMmmmdP'   "/>
                <LineBreak/> 
            </TextBlock>
            <Button x:Name="ADKickstarter">Kickstarter</Button>
            <Button x:Name="ChangeDefaultPassword">Change Default Password for All Users</Button>
          </StackPanel>
        </Grid>
      </TabItem>
      <TabItem Header="Updates">
        <Grid Background="#FF2D2D30">
          <StackPanel Orientation="Vertical">
            <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="Red" Margin="10">
                <Run Text="██    ██ ██████  ██████   █████  ████████ ███████ ███████ "/>
                <LineBreak/>
                <Run Text="██    ██ ██   ██ ██   ██ ██   ██    ██    ██      ██      "/>
                <LineBreak/>
                <Run Text="██    ██ ██████  ██   ██ ███████    ██    █████   ███████ "/>
                <LineBreak/>
                <Run Text="██    ██ ██      ██   ██ ██   ██    ██    ██           ██ "/>
                <LineBreak/>
                <Run Text=" ██████  ██      ██████  ██   ██    ██    ███████ ███████ "/>
                <LineBreak/>
            </TextBlock>
            <Button x:Name="UpdatesKickstarter">Kickstarter</Button>
            <Button x:Name="BruteForceUpdating">Brute Force Updating</Button>
          </StackPanel>
        </Grid>
      </TabItem>
      <TabItem Header="General Security">
        <Grid Background="#FF2D2D30">
          <StackPanel Orientation="Vertical">
            <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="White" Margin="10">
                <Run Text=" ▄▄ • ▄▄▄ . ▐ ▄ .▄▄ · ▄▄▄ . ▄▄· "/>
                <LineBreak/>
                <Run Text="▐█ ▀ ▪▀▄.▀·•█▌▐█▐█ ▀. ▀▄.▀·▐█ ▌▪"/>
                <LineBreak/>
                <Run Text="▄█ ▀█▄▐▀▀▪▄▐█▐▐▌▄▀▀▀█▄▐▀▀▪▄██ ▄▄"/>
                <LineBreak/>
                <Run Text="▐█▄▪▐█▐█▄▄▌██▐█▌▐█▄▪▐█▐█▄▄▌▐███▌"/>
                <LineBreak/>
                <Run Text="·▀▀▀▀  ▀▀▀ ▀▀ █▪ ▀▀▀▀  ▀▀▀ ·▀▀▀ "/>
                <LineBreak/>
            </TextBlock>
            <Button x:Name="RestartServices">Restart Services</Button>
            <Button x:Name="Sysinternals">Sysinternals</Button>
            <Button x:Name="Wireshark">Wireshark</Button>
            <Button x:Name="Snort">Snort</Button>
          </StackPanel>
        </Grid>
      </TabItem>
    </TabControl>
  </Grid>
</Window>
"@

[xml]$xamlUpdate = @"
<Window 
    x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="Windows Server 2012 Hardening" 
    SizeToContent="WidthAndHeight"
    ResizeMode="NoResize"
    Background="#FF2D2D30">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="Padding" Value="14"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#FF686868"/>
    </Style>
    <Style TargetType="TextBox">
      <Setter Property="Foreground" Value="#FF000000"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="TextAlignment" Value="Center"/>
    </Style>
  </Window.Resources>
  <Grid>
    <StackPanel Orientation="Vertical">
      <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="White" Margin="10">
      Which type of updates would you like to apply?
      </TextBlock>
      <Button x:Name="SecurityUpdates">Only security updates</Button>
      <Button x:Name="QualityUpdates">Only quality updates</Button>
      <Button x:Name="BothUpdates">Both</Button>
      <TextBox x:Name="AfterDate" Text="After Date (mm/dd/yyyy)"/>
    </StackPanel>
  </Grid>
</Window>
"@

[xml]$xamlRestart = @"
<Window 
    x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="Windows Server 2012 Hardening"
    SizeToContent="WidthAndHeight"
    ResizeMode="CanMinimize"
    Background="#FF2D2D30">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="Padding" Value="14"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#FF686868"/>
    </Style>
  </Window.Resources>
  <Grid>
    <StackPanel Orientation="Vertical">
      <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="White" Margin="10">
      Which services would you like to restart?
      </TextBlock>
      <Button x:Name="AD">Active Directory</Button>
      <Button x:Name="DNS">DNS</Button>
      <Button x:Name="DHCP">DHCP</Button>
    </StackPanel>
  </Grid>
</Window>
"@

[xml]$xamlSysinternals = @"
<Window 
    x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="Windows Server 2012 Hardening"
    SizeToContent="WidthAndHeight"
    ResizeMode="NoResize"
    Background="#FF2D2D30">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="Padding" Value="14"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="BorderBrush" Value="#FF686868"/>
    </Style>
  </Window.Resources>
  <Grid>
    <StackPanel Orientation="Vertical">
      <TextBlock FontFamily="Consolas" TextAlignment="Center" Foreground="White" Margin="10">
      Sysinternals Suite
      </TextBlock>
      <Button x:Name="Sysmon">Sysmon</Button>
      <Button x:Name="Lorem">Lorem ipsum</Button>
      <Button x:Name="Ipsum">Lorem ipsum</Button>
    </StackPanel>
  </Grid>
</Window>
"@

[xml]$xamlFirewallRules = @"
<Window 
    x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="Windows Server 2012 Hardening" 
    SizeToContent="WidthAndHeight"
    ResizeMode="NoResize"
    Background="#FF2D2D30">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="1"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="HorizontalAlignment" Value="Right"/>
    </Style>
    <Style TargetType="TextBox">
      <Setter Property="Foreground" Value="#FF000000"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
    </Style>
    <Style TargetType="ComboBox">
      <Setter Property="Foreground" Value="#FF333333"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="Width" Value="390"/>
      <Setter Property="IsEditable" Value="False"/>
    </Style>
  </Window.Resources>
  <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="569"/>
            <ColumnDefinition Width="16"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="550"/>
            <RowDefinition Height="25"/>
            <RowDefinition/>
        </Grid.RowDefinitions>    
        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="150"/>
                <ColumnDefinition Width="20"/>
                <ColumnDefinition Width="400"/>
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
                <RowDefinition Height="50"/>
            </Grid.RowDefinitions>
            <TextBlock Grid.Column="0" Grid.Row="0">Display Name:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="1">Description:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="2">Program:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="3">Direction:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="4">Profile(s):</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="5">Action:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="6">Protocol:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="7">Local Address(es):</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="8">Local Ports:</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="9">Remote Address(es):</TextBlock>
            <TextBlock Grid.Column="0" Grid.Row="10">Remote Ports:</TextBlock>
            <TextBox Name="DisplayName" Grid.Column="2" Grid.Row="0"/>
            <TextBox Name="Description" Grid.Column="2" Grid.Row="1"/>
            <TextBox Name="Program" Grid.Column="2" Grid.Row="2" HorizontalAlignment="Left" Width="350"/>
            <Button Name="ProgramBtn" Grid.Column="2" Grid.Row="2" HorizontalAlignment="Right" Height="20" Width="20">...</Button>
            <ComboBox Name="Direction" Grid.Column="2" Grid.Row="3">
                <ComboBoxItem Content="Inbound"/>
                <ComboBoxItem Content="Outbound"/>
            </ComboBox>
            <ComboBox Name="Profile" Grid.Column="2" Grid.Row="4">
                <ComboBoxItem Content="None"/>
                <ComboBoxItem Content="All"/>
                <ComboBoxItem Content="Public"/>
                <ComboBoxItem Content="Private"/>
                <ComboBoxItem Content="Domain"/>
                <ComboBoxItem Content="Public, Private"/>
                <ComboBoxItem Content="Public, Domain"/>
                <ComboBoxItem Content="Private, Domain"/>
            </ComboBox>
            <ComboBox Name="Action" Grid.Column="2" Grid.Row="5">
                <ComboBoxItem Content="None"/>
                <ComboBoxItem Content="Block"/>
                <ComboBoxItem Content="Allow"/>
            </ComboBox>
            <ComboBox Name="Protocol" Grid.Column="2" Grid.Row="6">
                <ComboBoxItem Content="TCP"/>
                <ComboBoxItem Content="UDP"/>
            </ComboBox>
            <TextBox Name="LocalAddress" Grid.Column="2" Grid.Row="7"/>
            <TextBox Name="LocalPorts" Grid.Column="2" Grid.Row="8"/>
            <TextBox Name="RemoteAddress" Grid.Column="2" Grid.Row="9"/>
            <TextBox Name="RemotePorts" Grid.Column="2" Grid.Row="10"/>
        </Grid>
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="400"/>
                <ColumnDefinition/>
                <ColumnDefinition/>
            </Grid.ColumnDefinitions>
            <Button Name="Cancel" Grid.Column="1" VerticalAlignment="Top">Cancel</Button>
            <Button Name="Submit" Grid.Column="2" VerticalAlignment="Top">Sumbit</Button>
        </Grid>
    </Grid>
</Window>
"@

[xml]$xamlFirewallKickstarter = @"
<Window 
    x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    Title="Windows Server 2012 Hardening" 
    SizeToContent="WidthAndHeight"
    ResizeMode="NoResize"
    Background="#FF2D2D30">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="1"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="HorizontalAlignment" Value="Right"/>
    </Style>
    <Style TargetType="TextBox">
      <Setter Property="Foreground" Value="#FF000000"/>
      <Setter Property="FontSize" Value="14"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
    </Style>
    <Style TargetType="Button">
      <Setter Property="Foreground" Value="#FFF1F1F1"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
    </Style>
    <Style TargetType="ComboBox">
      <Setter Property="Foreground" Value="#FF333333"/>
      <Setter Property="Background" Value="#FF3F3F46"/>
      <Setter Property="Margin" Value="5"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="Width" Value="390"/>
      <Setter Property="IsEditable" Value="False"/>
    </Style>
  </Window.Resources>
  <Grid>

  </Grid>
</Window>
"@

# Web client for downloads and such
$webClient = New-Object System.Net.WebClient
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12          

$readerMain = (New-Object System.Xml.XmlNodeReader $xamlMain)
$windowMain = [Windows.Markup.XamlReader]::Load($readerMain)


# Functions for implementing actions
function FireWallKickstarter_Click
{
  # Display XAML for entering in splunk, firewall, DHCP, DNS, ecomm, etc.

  $readerFirewallKickstarter = (New-Object System.Xml.XmlNodeReader $xamlFirewallKickstarter)
  $windowFirewallKickstarter = [Window.Markup.XamlReader]::Load($readerFirewallKickstarter)

  $windowFirewallKickStarter.ShowDialog() | Out-Null

  # Open relevant ports

  #New-NetFirewallRule -DisplayName "" -Description ""
  #New-NetFirewallRule -DisplayName "" -Description ""
  #New-NetFirewallRule -DisplayName "" -Description ""
  #New-NetFirewallRule -DisplayName "" -Description ""
  #New-NetFirewallRule -DisplayName "" -Description ""
  #New-NetFirewallRule -DisplayName "" -Description ""
  #New-NetFirewallRule -DisplayName "" -Description ""

  # Display another XAML menu that will ask to enable logging, where to store logs etc.

}

function CreateRule_Click
{
  #$readerFirewallRules = (New-Object System.Xml.XmlNodeReader $xamlFirewallRules)
  #$windowFirewallRules = [Windows.Markup.XamlReader]::Load($readerFirewallRules)
  #
  #function ProgramBtnClick
  #{
  #  $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  #  $openFileDialog.InitialDirectory = $env:USERPROFILE
  #  $dialogResult = $openFileDialog.ShowDialog()
  #
  #  if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK)
  #  {
  #    $selectedFile = $openFileDialog.FileName
  #    $windowFirewallRules.FindName("Program").Text=$selectedFile
  #  }
  #}
  #
  #$windowFirewallRules.FindName("ProgramBtn").Add_Click({ ProgramBtnClick })
  #$windowFirewallRules.FindName("Submit").Add_Click({ 
  #  $firewallParameters = @{
  #    DisplayName = $windowFirewallRules.FindName("DisplayName").Text
  #    Description = $windowFirewallRules.FindName("Description").Text
  #    Program = $selectedFile
  #    Direction = $windowFirewallRules.FindName("Direction").Text
  #    Profile = $windowFirewallRules.FindName("Profile").Text
  #    Action = $windowFirewallRules.FindName("Action").Text
  #    Protocol = $windowFirewallRules.FindName("Protocol").Text
  #    LocalPort = $windowFirewallRules.FindName("LocalPorts").Text
  #    RemoteAdress = $windowFirewallRules.FindName("RemoteAddress").Text
  #    RemotePorts = $windowsFirewallRules.FindName("RemotePorts").Text    
  #  }
  #  New-NetFirewallRule @firewallParameters;
  #  [System.Windows.MessageBox]::Show("Firewall OK", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) })
  #
  #  $windowFirewallRules.ShowDialog() | Out-Null
}

function ModifyRule_Click
{
  [System.Windows.MessageBox]::Show("ModifyRule button has been clicked.", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
  
}

function CodeRed_Click
{
  [System.Windows.MessageBox]::Show("CodeRed button has been clicked.", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
  
}

function ADKickstarter_Click
{
  [System.Windows.MessageBox]::Show("ADKickstarter button has been clicked.", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
  
}

function ChangeDefaultPassword_Click
{
  [System.Windows.MessageBox]::Show("ChangeDefaultPassword button has been clicked.", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)

}

function UpdatesKickstarter_Click
{
  [System.Windows.MessageBox]::Show("UpdatesKickstarter button has been clicked.", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
  
}

function BruteForceUpdating_Click
{
  [System.Windows.MessageBox]::Show("This updates the server from a csv list.`nWARNING: Make sure csv has headers UpdateName and Hyperlinks.", "Alert", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)

  # Create an instance of the OpenFileDialog class
  $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

  # Set the properties of the OpenFileDialog, this updater requires a csv file
  $openFileDialog.InitialDirectory = $env:USERPROFILE
  $openFileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"

  # Show the OpenFileDialog and wait for the user to select a file
  $dialogResult = $openFileDialog.ShowDialog()

  # If the user selected a file, ensure it is a csv and has proper headers
  if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK)
  {
    $selectedFile = $openFileDialog.FileName
    if([System.IO.Path]::GetExtension($selectedFile) -ne ".csv")
    {
      [System.Windows.MessageBox]::Show("Error: Incorrect file type.","Alert",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
    else
    {
      $csvFile = Import-Csv $selectedFile
      if((($csvFile[0].PSObject.Properties.Name)[0] -ne "UpdateName") -or (($csvFile[0].PSObject.Properties.Name)[1] -ne "Hyperlinks"))
      {
        [System.Windows.MessageBox]::Show("Error: Incorrect headers.","Alert",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
      }
      else
      {
        [System.Windows.MessageBox]::Show("CSV imported.","Alert",[System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        $readerUpdate = (New-Object System.Xml.XmlNodeReader $xamlUpdate)
        $windowUpdate = [Windows.Markup.XamlReader]::Load($readerUpdate)

        function SecurityUpdates_Click
        {
          $script:csvUpdates = Import-Csv $selectedFile | Where-Object {$_.Hyperlinks -like "*/secu/*"}
        }

        function QualityUpdates_Click
        {
          $script:csvUpdates = Import-Csv $selectedFile | Where-Object {$_.Hyperlinks -like "*/updt/*"}
        }

        function BothUpdates_Click
        {
          $script:csvUpdates = $selectedFile
        }

        function AfterDate_Enter
        {
          # Needs improvement
        }

        $windowUpdate.FindName("SecurityUpdates").Add_Click({ SecurityUpdates_Click; $windowUpdate.close() })
        $windowUpdate.FindName("QualityUpdates").Add_Click({ QualityUpdates_Click; $windowUpdate.close() })
        $windowUpdate.FindName("BothUpdates").Add_Click({ BothUpdates_Click; $windowUpdate.close() })
        $windowUpdate.FindName("AfterDate").Add_KeyDown({ AfterDate_Enter; $windowUpdate.close() })

        $windowUpdate.ShowDialog() | Out-Null
        
        if($null -ne $csvUpdates)
        {
          $ErrorActionPreference = 'SilentlyContinue'
          $progressForm = [System.Windows.Forms.Form] @{ TopMost = $true; Text = "Updating..."; MinimizeBox = $false; MaximizeBox = $false; Width = 400; Height = 200; StartPosition = "CenterScreen"}
          $progressForm.Controls.AddRange(
          @(
            [System.Windows.Forms.Label] @{ Name = 'label'; Top = 30 ; Left = 25; Width = 350 }
            [System.Windows.Forms.ProgressBar] @{ Name = 'bar'; Minimum = 0; Maximum = 100; Top = 50; Left = 25; Width = 350}
          ))
          $progressForm.Add_FormClosing(
            {
              $confirmation = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to cancel updates?","Confirmation",[System.Windows.Forms.MessageBoxButton]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)

              if ($confirmation -ne [System.Windows.Forms.DialogResult]::Yes)
              {
                $eventArgs.Cancel = $true
              }
            }
          )

          $progressForm.Show()

          mkdir $env:temp\updates\ -ErrorAction SilentlyContinue | Out-Null
          $counter = 1;

          foreach($csvUpdate in $csvUpdates)
          {
            if($progressForm.Visible)
            {
              $progressForm.Controls['label'].Text = "Downloading update $($csvUpdate.UpdateName) ($($counter) out of $($csvUpdates.Length))"
              $progressForm.Controls['bar'].Value = (($counter)/$csvUpdates.Length)*100
              $progressForm.Refresh();
              [System.Windows.Forms.Application]::DoEvents()

              $webClient.DownloadFile($csvUpdate.Hyperlinks,"$env:temp\updates\$($csvUpdate.UpdateName).msu")
              
              $progressForm.Controls['label'].Text = "Installing update $($csvUpdate.UpdateName) ($($counter) out of $($csvUpdates.Length))"
              $progressForm.Refresh();
              [System.Windows.Forms.Application]::DoEvents()

              Start-Process -FilePath "$env:temp\updates\$($csvUpdate.UpdateName).msu" -ArgumentList "/quiet","/norestart" -Wait
              
              $counter++

              Start-Sleep -Seconds 1
            }
          }
          
          $ErrorActionPreference = 'Continue'
          $progressForm.Dispose()
        }
      }
    }
  }
}

function AD_Click
{
  $confirmAD = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to restart Active Directory?","Confirmation",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
  if ($confirmAD -eq [System.Windows.Forms.DialogResult]::Yes)
  {
    if(Get-Service | Where-Object {$_.Name -eq "NTFS"})
    {
      Restart-Service NTFS -Force
    }
    else
    {
      [System.Windows.Forms.MessageBox]::Show("Active Directory service not found","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    }
  }
}

function DNS_Click
{
  $confirmDNS = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to restart DNS?","Confirmation",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
  if ($confirmDNS -eq [System.Windows.Forms.DialogResult]::Yes)
  {
    if(Get-Service | Where-Object {$_.Name -eq "DNS"})
    {
      Restart-Service DNS -Force
    }
    else
    {
      [System.Windows.Forms.MessageBox]::Show("DNS service not found","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    }
  }
}

function DHCP_Click
{
  $confirmDHCP = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to restart DHCP?","Confirmation",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
  if ($confirmDHCP -eq [System.Windows.Forms.DialogResult]::Yes)
  {
    if(Get-Service | Where-Object {$_.Name -eq "DHCPServer"})
    {
      Restart-Service DHCPServer -Force
    }
    else
    {
      [System.Windows.Forms.MessageBox]::Show("DHCP service not found","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    }
  }
}

function RestartServices_Click
{
  $readerRestart = (New-Object System.Xml.XmlNodeReader $xamlRestart)
  $windowRestart = [Windows.Markup.XamlReader]::Load($readerRestart)

  $windowRestart.FindName("AD").Add_Click({ AD_Click })
  $windowRestart.FindName("DNS").Add_Click({ DNS_Click })
  $windowRestart.FindName("DHCP").Add_Click({ DHCP_Click })

  $windowRestart.Show()
}


function Sysmon_Click
{
  if((powershell "C:\Windows\SysInternalsSuite\sysmon.exe -i") -like "*already registered*")
  {
    Write-Host "Sysmon already installed"
  }
  else
  {
    $confirmSysmonInstall = [System.Windows.Forms.MessageBox]::Show("Sysmon not detected, install now?","Confirmation",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
    if($confirmSysmonInstall -eq [System.Windows.Forms.DialogResult]::Yes)
    {
      Invoke-RestMethod https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml | Out-File C:\Windows\SysInternalsSuite\sysmonconfig-export.xml
      powershell "C:\Windows\SysInternalsSuite\sysmon.exe -accepteula -i C:\Windows\SysInternalsSuite\sysmonconfig-export.xml"
    }
  }
}

function Sysinternals_Click
{
  if(Test-Path C:\Windows\SysInternalsSuite)
  {
    $readerSysinternals = (New-Object System.Xml.XmlNodeReader $xamlSysinternals)
    $windowSysinternals = [Windows.Markup.XamlReader]::Load($readerSysinternals)

    $windowSysinternals.FindName("Sysmon").Add_Click({ Sysmon_Click })

    $windowSysinternals.Show()
  }
  elseif(Test-Path C:\Windows\SysInternalsSuite.zip)
  {
    $confirmSysUnzip = [System.Windows.Forms.MessageBox]::Show("Unzip Sysinternals?","Confirmation",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
    if($confirmSysUnzip -eq [System.Windows.Forms.DialogResult]::Yes)
    {
      Expand-Archive -Path C:\Windows\SysInternalsSuite -DestinationPath C:\Windows\SysInternalsSuite -Force
    }
  }
  else
  {
    $confirmSysinternals = [System.Windows.Forms.MessageBox]::Show("Sysinternals Suite is not detected, install now?","Confirmation",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
    if($confirmSysinternals -eq [System.Windows.Forms.DialogResult]::Yes)
    {
      $sysinternalsInstall = [System.Windows.Forms.MessageBox]::Show("Installing...","SysInternals",[System.Windows.Forms.MessageBoxIcon]::Information)
      $webClient.DownloadFile("https://download.sysinternals.com/files/SysinternalsSuite.zip","C:\Windows\SysInternalsSuite.zip") | Wait-Event
      $null = $sysinternalsInstall
    }
  }
}

function Wireshark_Click
{

}

function Snort_Click
{

}

# Assigning event handlers for buttons
$windowMain.FindName("FireWallKickstarter").Add_Click({ FireWallKickstarter_Click })
$windowMain.FindName("CreateRule").Add_Click({ CreateRule_Click })
$windowMain.FindName("ModifyRule").Add_Click({ ModifyRule_Click })
$windowMain.FindName("CodeRed").Add_Click({ CodeRed_Click })
$windowMain.FindName("ADKickstarter").Add_Click({ ADKickstarter_Click })
$windowMain.FindName("ChangeDefaultPassword").Add_Click({ ChangeDefaultPassword_Click })
$windowMain.FindName("UpdatesKickstarter").Add_Click({ UpdatesKickstarter_Click })
$windowMain.FindName("BruteForceUpdating").Add_Click({ BruteForceUpdating_Click })
$windowMain.FindName("RestartServices").Add_Click({ RestartServices_Click })
$windowMain.FindName("Sysinternals").Add_Click({ Sysinternals_Click })
$windowMain.FindName("Wireshark").Add_Click({ Wireshark_Click })
$windowMain.FindName("Snort").Add_Click({ Snort_Click })

# Running the GUI
$windowMain.ShowDialog() | Out-Null