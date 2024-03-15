import { Component } from '@angular/core';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css',
})
export class NavbarComponent {
  public getTheme() {
    const theme = localStorage.getItem('theme') || 'fantasy';
    console.log('theme');
    return theme === 'fantasy';
  }
}
